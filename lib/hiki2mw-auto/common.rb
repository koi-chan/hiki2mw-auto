# encoding: utf-8

# 引数チェック
unless ARGV.length == 1
  STDERR.puts "Usage: ruby #{$0} HIKI_DATA_DIR"
  abort
end

module Hiki2MW
  module Auto
    DATA_DIR = ARGV[0]
    INFO_DB = File.join(DATA_DIR, "info.db")
    TEXT_DIR = File.join(DATA_DIR, "text")

    HIKI2MW_DIR = File.join(DATA_DIR, "hiki2mw")
    CONFIG_DIR = File.join(HIKI2MW_DIR, "config")
    AUTO_POST_CONF = File.join(CONFIG_DIR, "auto-post.conf")
    PAGES_TO_POST = File.join(CONFIG_DIR, "pages-to-post.csv")
    TEXT_MW_DIR = File.join(HIKI2MW_DIR, "text-mw")
    LINKS_DIR = File.join(HIKI2MW_DIR, "links")
    PAGES_INFO_DIR = File.join(HIKI2MW_DIR, "pages-info")

    # 設定クラス
    class AutoPostConfig
      def self.load(path)
        c = new()
        c.instance_eval File.read(path)
        c
      end

      attr_reader :hiki_uri, :hiki_encoding,
        :mediawiki_uri, :username, :password, :wait_time
    end

    module_function
    # エラーメッセージを標準エラー出力に出力して終了する
    def die(message)
      STDERR.puts "#{$0}: #{message}"
      abort
    end
  end
end
