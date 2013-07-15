# encoding: utf-8

require "csv"
require "fileutils"
require_relative "hiki2mw-auto/common"

HIKI_ENCODING = Encoding::EUCJP
OUTPUT_ENCODING = Encoding::UTF_8

# ディレクトリ・ファイルの準備
unless File.exist?(Hiki2MW::Auto::INFO_DB)
  Hiki2MW::Auto.die "No such file - #{Hiki2MW::Auto::INFO_DB}"
end

begin
  [Hiki2MW::Auto::PAGES_INFO_DIR, Hiki2MW::Auto::CONFIG_DIR].each do |dir|
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
  end
rescue => e
  Hiki2MW::Auto.die e
end

# info.db の読み込み
info = eval(File.read(Hiki2MW::Auto::INFO_DB))

# タイトルの妥当性で分ける
pages_valid_title = {}
pages_invalid_title = {}
info.each do |k, v|
  title = v[:title]
  title.force_encoding(HIKI_ENCODING).encode!(OUTPUT_ENCODING)

  # () で終わるタイトルの場合、( の前に空白を挿入する
  if title[-1] == ")" && (lparen_index = title.rindex("(")) &&
      lparen_index != 0 && title[lparen_index - 1] != " "
    title.insert(lparen_index, " ")
  end

  valid_title = !(title == "." || title == ".." ||
                  %r!\A\.?\./! =~ title || %r!/\.?\./! =~ title ||
                  %r!/\.?\.\Z! =~ title ||
                  %r![#<>\[\]|{}/:%+?&]|~{3,}! =~ title)
  if valid_title
    pages_valid_title[k] = title
  else
    pages_invalid_title[k] = title
  end
end

# 出力
unless pages_valid_title.empty?
  filename_valid_title = File.join(Hiki2MW::Auto::PAGES_INFO_DIR,
                                   "pages-valid-title.csv")
  CSV.open(filename_valid_title, "w") do |csv|
    csv << [:Filename, :Title]
    pages_valid_title.each {|k, v| csv << [k, v]}
  end
  puts "Exported #{filename_valid_title}"

  FileUtils.cp(filename_valid_title, Hiki2MW::Auto::PAGES_TO_POST)
  puts "Copied #{filename_valid_title} to #{Hiki2MW::Auto::PAGES_TO_POST}"
end

unless pages_invalid_title.empty?
  filename_invalid_title = File.join(Hiki2MW::Auto::PAGES_INFO_DIR,
                                     "pages-invalid-title.csv")
  CSV.open(filename_invalid_title, "w") do |csv|
    csv << [:Filename, :Title]
    pages_invalid_title.each {|k, v| csv << [k, v]}
  end
  puts "Exported #{filename_invalid_title}"
end
