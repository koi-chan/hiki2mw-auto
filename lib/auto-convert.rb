# encoding: utf-8

require "fileutils"
require "kconv"
require "csv"
require_relative "hiki2mw-ruby/hiki2mw/converter"
require_relative "hiki2mw-ruby/hiki2mw/link-analyzer"
require_relative "hiki2mw-auto/common"

# ディレクトリの準備
unless Dir.exist?(Hiki2MW::Auto::TEXT_DIR)
  Hiki2MW::Auto.die "No such directory - #{Hiki2MW::Auto::TEXT_DIR}"
end

begin
  [Hiki2MW::Auto::TEXT_MW_DIR, Hiki2MW::Auto::LINKS_DIR].each do |dir|
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
  end
rescue => e
  Hiki2MW::Auto.die e
end

# 変換・リンク解析
converter = Hiki2MW::Converter.new("", :convert_parened_links => true)
link_analyzer = Hiki2MW::LinkAnalyzer.new(
  "", Hiki2MW::LinkAnalyzer::MODE_MEDIAWIKI
)

Dir.glob(File.join(Hiki2MW::Auto::TEXT_DIR, "*")) do |filename|
  filename_mw = File.join(Hiki2MW::Auto::TEXT_MW_DIR, File.basename(filename))
  filename_links = File.join(Hiki2MW::Auto::LINKS_DIR,
                             File.basename(filename) + ".csv")

  # 変換
  converter.source = File.read(filename).toutf8
  source_mw = converter.convert

  # 変換結果を出力
  File.write(filename_mw, source_mw)
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
