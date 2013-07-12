Hiki2MediaWiki Auto
===================
[Hiki2MediaWiki Ruby 版](https://github.com/ochaochaocha3/hiki2mw-ruby) と連携して、Hiki から MediaWiki の移植を自動で行うためのツールです。Hiki の data ディレクトリの内容を利用します。

動作環境
--------
* Unix か Linux か Cygwin（Cygwin は動作未確認）
* Ruby 1.9.2 以降
* Git
* UTF-8 対応のエディタ

インストール
------------
1. 適当なディレクトリで以下を実行し、ダウンロードする。

        $ git clone https://github.com/ochaochaocha3/hiki2mw-auto.git

2. 生成された hiki2mw-auto ディレクトリに移動する。

3. 以下を実行して、Hiki2MediaWiki Ruby 版をダウンロードする。

        $ git clone https://github.com/ochaochaocha3/hiki2mw-ruby.git lib/hiki2mw-ruby

使い方
------
1. 移植したい Hiki の文字コードを調べ、info2csv.rb 冒頭の `HIKI_ENCODING` をそれに合わせる。

    * EUC-JP（Hiki 1.0.0 未満；デフォルト）：`HIKI_ENCODING = Encoding::EUCJP`
    * UTF-8（Hiki 1.0.0 以降）：`HIKI_ENCODING = Encoding::UTF_8`

2. 移植したい Hiki の data ディレクトリを適当な場所に配置する。以下、それを data とする。

    場所はどこでも構いませんが、Wiki 名に改名して hiki2mw-auto ディレクトリに配置すると分かりやすくなります。

3. hiki2mw-auto ディレクトリに移動する。

4. 以下を実行する。

        $ ./step1.sh data
