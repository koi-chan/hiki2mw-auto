# encoding: utf-8

require "csv"
require "fileutils"

HIKI_ENCODING = Encoding::EUCJP
OUTPUT_ENCODING = Encoding::UTF_8

# エラーメッセージを標準エラー出力に出力して終了する
def die(message)
  STDERR.puts message
  abort
end

# 引数チェック
die "Usage: ruby #{__FILE__} HIKI_DATA_DIR" unless ARGV.length == 1

# ディレクトリ・ファイルの準備
data_dir = ARGV[0]
info_db = File.join(data_dir, "info.db")
die "#{__FILE__}: No such file - #{info_db}" unless File.exist?(info_db)

hiki2mw_dir = File.join(data_dir, "hiki2mw")
pages_info_dir = File.join(hiki2mw_dir, "pages-info")
config_dir = File.join(hiki2mw_dir, "config")
begin
  [pages_info_dir, config_dir].each do |dir|
    FileUtils.mkdir_p dir unless Dir.exist? dir
  end
rescue => e
  die "#{__FILE__}: #{e}"
end

# info.db の読み込み
info = eval(File.open(info_db, "r") {|f| f.read})

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
  filename_valid_title = File.join(pages_info_dir, "pages-valid-title.csv")
  CSV.open(filename_valid_title, "w") do |csv|
    csv << [:Filename, :Title]
    pages_valid_title.each {|k, v| csv << [k, v]}
  end
  puts "Exported #{filename_valid_title}"

  filename_to_post = File.join(config_dir, "pages-to-post.csv")
  FileUtils.cp(filename_valid_title, filename_to_post)
  puts "Copied #{filename_valid_title} to #{filename_to_post}"
end

unless pages_invalid_title.empty?
  filename_invalid_title = File.join(pages_info_dir, "pages-invalid-title.csv")
  CSV.open(filename_invalid_title, "w") do |csv|
    csv << [:Filename, :Title]
    pages_invalid_title.each {|k, v| csv << [k, v]}
  end
  puts "Exported #{filename_invalid_title}"
end
