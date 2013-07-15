require "rubygems"
require "media_wiki"
require "csv"
require "uri"

# 設定クラス
class AutoPostConfig
  def self.load(path)
    c = new()
    c.instance_eval File.read(path)
    c
  end

  attr_reader :mediawiki_url, :username, :password, :wait_time
end

# エラーメッセージを標準エラー出力に出力して終了する
def die(message)
  STDERR.puts message
  abort
end

# 引数チェック
die "Usage: ruby #{__FILE__} HIKI_DATA_DIR" unless ARGV.length == 1

# 設定ファイルの準備
data_dir = ARGV[0]
hiki2mw_dir = File.join(data_dir, "hiki2mw")
text_mw_dir = File.join(hiki2mw_dir, "text-mw")
config_dir = File.join(hiki2mw_dir, "config")
filename_config = File.join(config_dir, "auto-post.conf")
filename_pages = File.join(config_dir, "pages-to-post.csv")
[filename_config, filename_pages].each do |fn|
  die "#{__FILE__}: No such file - #{fn}" unless File.exist?(fn)
end

config = AutoPostConfig.load(filename_config)
pages = CSV.read(filename_pages, :headers => :first_row)

# MediaWiki へのログイン
begin
  api_url = URI.join(config.mediawiki_url, "api.php").to_s
  mw = MediaWiki::Gateway.new(api_url, :bot => true)
  mw.login(config.username, config.password)
rescue MediaWiki::Exception
  die "#{__FILE__}: Login failed"
rescue => e
  die "#{__FILE__}: #{e}"
end

# ページ投稿
pages.each do |row|
  filename = File.join(text_mw_dir, row[0])
  title = row[1]
  begin
    source_mw = File.read(filename)
    mw.edit(title, source_mw, :summary => "Hiki からの自動変換")

    puts "Posted #{title}"
    sleep config.wait_time
  rescue MediaWiki::Exception
    puts "Post failed: #{title}"
    sleep config.wait_time
  rescue => e
    STDERR.puts "#{__FILE__}: #{e}"
  end
end
