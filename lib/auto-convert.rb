# encoding: utf-8

require "fileutils"
require "kconv"
require "csv"
require_relative "hiki2mw-ruby/hiki2mw/converter"
require_relative "hiki2mw-ruby/hiki2mw/link-analyzer"

# エラーメッセージを標準エラー出力に出力して終了する
def die(message)
  STDERR.puts message
  abort
end

# 引数チェック
die "Usage: ruby #{__FILE__} HIKI_DATA_DIR" unless ARGV.length == 1

# ディレクトリの準備
data_dir = ARGV[0]
text_dir = File.join(data_dir, "text")
die "#{__FILE__}: No such directory - #{text_dir}" unless Dir.exist?(text_dir)

hiki2mw_dir = File.join(data_dir, "hiki2mw")
text_mw_dir = File.join(hiki2mw_dir, "text-mw")
links_dir = File.join(hiki2mw_dir, "links")
begin
  [text_mw_dir, links_dir].each do |dir|
    FileUtils.mkdir_p dir unless Dir.exist? dir
  end
rescue => e
  die "#{__FILE__}: #{e}"
end

# 変換・リンク解析
converter = Hiki2MW::Converter.new("", :convert_parened_links => true)
link_analyzer = Hiki2MW::LinkAnalyzer.new(
  "", Hiki2MW::LinkAnalyzer::MODE_MEDIAWIKI
)

Dir.glob(File.join(text_dir, "*")) do |filename|
  filename_mw = File.join(text_mw_dir, File.basename(filename))
  filename_links = File.join(links_dir, File.basename(filename) + ".csv")

  # 変換
  converter.source = File.open(filename, "r") {|f| f.read}.toutf8
  source_mw = converter.convert

  # 変換結果を出力
  File.open(filename_mw, "w") {|f| f.print source_mw}
  puts "Exported #{filename_mw}"

  # リンク解析
  link_analyzer.source = source_mw
  links = link_analyzer.analyze

  # リンク解析結果を出力
  alphabetical = !(links[:alphabetical].empty?)
  parened = !(links[:parened].empty?)
  wikiname = !(links[:wikiname].empty?)
  if alphabetical || parened || wikiname
    br = false
    CSV.open(filename_links, "w") do |csv|
      if alphabetical
        br = true
        csv << ["[英字名ページへのリンク]"]
        csv << ["#", "行", "桁", "リンク", "ページ名"]

        links[:alphabetical].each.with_index(1) do |h, i|
          csv << [i, h[:line_num], h[:char_num], h[:link], h[:page_name]]
        end
      end

      if parened
        csv << [""] if br
        br = true
        csv << ["[括弧を含む名前のページへのリンク]"]
        csv << ["#", "行", "桁", "リンク", "ページ名"]

        links[:parened].each.with_index(1) do |h, i|
          csv << [i, h[:line_num], h[:char_num], h[:link], h[:page_name]]
        end
      end

      if wikiname
        csv << [""] if br
        csv << ["WikiName"]
        csv << ["#", "行", "桁", "WikiName"]

        links[:wikiname].each.with_index(1) do |h, i|
          csv << [i, h[:line_num], h[:char_num], h[:page_name]]
        end
      end
    end

    puts "Exported #{filename_links}"
  end
end
