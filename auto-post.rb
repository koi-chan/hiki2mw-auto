# encoding: utf-8

require "rubygems"
require "media_wiki"
require "csv"
require "uri"
require_relative "lib/hiki2mw-auto/common"

# 設定ファイルの準備
[Hiki2MW::Auto::AUTO_POST_CONF, Hiki2MW::Auto::PAGES_TO_POST].each do |fn|
  Hiki2MW::Auto.die "No such file - #{fn}" unless File.exist?(fn)
end

config = Hiki2MW::Auto::AutoPostConfig.load(Hiki2MW::Auto::AUTO_POST_CONF)
pages = CSV.read(Hiki2MW::Auto::PAGES_TO_POST, :headers => :first_row)

# MediaWiki へのログイン
begin
  api_uri = URI.join(config.mediawiki_uri, "api.php").to_s
  mw = MediaWiki::Gateway.new(api_uri, :bot => true)
  mw.login(config.username, config.password)
rescue MediaWiki::Exception
  Hiki2MW::Auto.die "Login failed"
rescue => e
  Hiki2MW::Auto.die e
end

# ページ投稿
pages.each do |row|
  filename = File.join(Hiki2MW::Auto::TEXT_MW_DIR, row[0])
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
    STDERR.puts "#{$0}: #{e}"
  end
end
