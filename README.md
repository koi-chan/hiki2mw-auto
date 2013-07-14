Hiki2MediaWiki Auto
===================
[Hiki2MediaWiki Ruby 版](https://github.com/ochaochaocha3/hiki2mw-ruby) と連携して、Hiki から MediaWiki の移植を自動で行うためのツールです。Hiki の data ディレクトリの内容を利用します。

以下の機能があります。

* Hiki ソースから MediaWiki ソースへの変換
* リンク切れの可能性があるリンクの報告
* ソースを変換したページの MediaWiki への自動投稿

動作環境
--------
* Unix か Linux か Cygwin（Cygwin は動作未確認）
* Ruby 1.9.2 以降
* Git
* UTF-8 対応のエディタ（設定ファイルを編集するときに使う。CSV ファイルは UTF-8 対応の表計算ソフトでも可）

インストール
------------
1. 以下を実行して、mediawiki-gateway をインストールします。

        $ gem install mediawiki-gateway

2. 適当なディレクトリで以下を実行し、ダウンロードします。

        $ git clone https://github.com/ochaochaocha3/hiki2mw-auto.git

3. 生成された hiki2mw-auto ディレクトリに移動します。

4. 以下を実行して、Hiki2MediaWiki Ruby 版をダウンロードします。

        $ git clone https://github.com/ochaochaocha3/hiki2mw-ruby.git lib/hiki2mw-ruby

使い方：自動変換
----------------
1. 移植したい Hiki の文字コードを調べ、lib/info2csv.rb 冒頭の `HIKI_ENCODING` をそれに合わせます。
    * EUC-JP（Hiki 1.0.0 未満；デフォルト）：`HIKI_ENCODING = Encoding::EUCJP`
    * UTF-8（Hiki 1.0.0 以降）：`HIKI_ENCODING = Encoding::UTF_8`

2. 移植したい Hiki の data ディレクトリを適当な場所に配置します。以下、このディレクトリのパスを DATA_DIR とします。

    場所はどこでも構いませんが、Wiki 名に改名して hiki2mw-auto ディレクトリに配置すると分かりやすくなります。

3. hiki2mw-auto ディレクトリに移動します。

4. 以下を実行します。

        $ ./auto-convert.sh DATA_DIR
        $ ./auto-convert.sh DATA_DIR | tee auto-convert.log（ログを記録する場合）

ここまでの操作で、以下のディレクトリ・ファイルが生成されます。

    - DATA_DIR/
    --- hiki2mw/
    ----- config/
    ------- auto-post.conf.sample（自動投稿の設定）
    ------- pages-to-post.csv（自動投稿するページの一覧）
    ----- links/
    ------- （リンク切れの可能性があるリンクの一覧；CSV 形式）
    ----- pages-info/
    ------- pages-invalid-title.csv（MediaWiki で使えない可能性がある名前のページの一覧）
    ------- pages-valid-title.csv（MediaWiki で使える名前のページの一覧）
    ----- text-mw/
    ------- （変換した MediaWiki ソース）

自動投稿の前に
--------------
自動投稿の実行前にいくつかの設定を行う必要があります。

### 投稿先の MediaWiki の設定
1. ボット用アカウントを作成します。アカウント名は例えば「Hiki2MediaWiki」。

2. 作成したアカウントの利用者グループを「ボット」に設定します。

### 自動投稿の設定ファイルの編集
1. DATA_DIR/hiki2mw/config/auto-post.conf.sample を auto-post.conf にリネームします。

2. auto-post.conf を投稿先の MediaWiki に合わせて編集します。

### 自動投稿するページの一覧の編集
DATA\_DIR/hiki2mw/config/pages-to-post.csv を編集します。自動変換直後の内容は DATA\_DIR/hiki2mw/pages-info/pages-valid-title.csv と同じです。書式は

    ソースファイル名,MediaWiki 上のページ名

です。

* 1行目はヘッダとして扱われるので消去しないでください。
* ソースファイル名は通常は変更する必要はありません。MediaWiki 上のページ名は自由に変更できます（サブページにする、名前空間を設定するなど）。
    * DATA_DIR/hiki2mw/pages-info/pages-invalid-title.csv の内容をコピーし、MediaWiki 上のページ名を適宜変更する、という作業が主体になります。

#### MediaWiki で使えない可能性があるページ名
この名前を持つページの一覧が DATA_DIR/hiki2mw/pages-info/pages-invalid-title.csv に書き出されます。

詳細は [Wikipedia:Naming conventions (technical restrictions)](http://en.wikipedia.org/wiki/Wikipedia:Naming_conventions_(technical_restrictions)) を参照してください。

* 禁止されている文字：`# < > [ ] | { }`
* スラッシュ `/` とピリオド `.`：スラッシュはサブページ機能を有効にしている場合に階層の区切りに使います（サブページとすることを意図する場合には問題ありません）。スラッシュとピリオドの組み合わせ（`./` か `../` で始まる、`/./` か `/../` を含む、`/.` か `/..` で終わる）は禁止されています。
* コロン `:`：名前空間や interwiki の接頭辞です。これらと被らなければ問題ありません。
* パーセント `%` とアンパサンド `&`：数字などが続くと HTML の実体参照として扱われる場合があります。
* 疑問符 `?` とプラス記号 `+`：URL のクエリ文字列の記号として扱われる場合があります。
* 3 連続のチルダ `~~~`：トークページで署名を書くときに使われます。

使い方：自動投稿
----------------
設定が完了したら、hiki2mw-auto ディレクトリに移動して以下を実行します。

    $ ruby auto-convert.rb DATA_DIR
    $ ruby auto-convert.rb DATA_DIR | tee auto-convert.log（ログを記録する場合）

自動投稿後の修正
----------------
投稿した各ページについて、DATA_DIR/links/ 以下のリンク解析結果を見ながらリンクを修正したり、カテゴリ・ソートキーを設定します。
