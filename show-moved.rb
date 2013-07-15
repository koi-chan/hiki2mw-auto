# encoding: utf-8

require "rubygems"
require "media_wiki"
require "csv"
require "uri"
require "xmlrpc/client"
require_relative "lib/hiki2mw-auto/common"

# 設定ファイルの準備
[Hiki2MW::Auto::INFO_DB, Hiki2MW::Auto::AUTO_POST_CONF,
    Hiki2MW::Auto::PAGES_TO_POST].each do |fn|
  Hiki2MW::Auto.die "No such file - #{fn}" unless File.exist?(fn)
end

info = eval(File.read(Hiki2MW::Auto::INFO_DB))
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

# Hiki の XML-RPC の準備
hiki_client = XMLRPC::Client.new2(config.hiki_uri)

# Hiki 上のページの編集
pages.each do |row|
  filename = row[0]
  title_mw = row[1]
  pagename_hiki = info[filename] &&
    CGI.unescape(filename).force_encoding(config.hiki_encoding) \
      .encode(Encoding::UTF_8)
  unless pagename_hiki
    puts "No such page in Hiki: #{filename}"
    next
  end
  title_hiki = info[filename][:title].force_encoding(config.hiki_encoding) \
    .encode(Encoding::UTF_8)

  # MediaWiki 上にページが存在するか
  if mw.get(title_mw)
    source_moved = <<EOS
新wikiに移植されました。

#{URI.join(config.mediawiki_uri, URI.encode(title_mw))}
EOS
    source_moved.chomp!
    begin
      hiki_client.call("wiki.putPage", pagename_hiki, source_moved,
                          "title" => title_hiki)
      puts "Edited on Hiki: #{title_hiki}"
    rescue XMLRPC::FaultException => fe
      puts "Edit on Hiki failed: #{title_hiki}: " +
        "#{fe.faultCode}: #{fe.faultString}"
    rescue => e
      STDERR.puts "#{$0}: #{e}"
    end
  else
    puts "No such page in MediaWiki: #{title_mw}"
  end

  sleep config.wait_time
end
