# テキスト・画像盗用防止アプリのサンプル

## アプリの設定

- クライアントIDとクライアントシークレットを .env.development に設定する

```bash
cd colormeshop-app-sample
echo COLORMESHOP_CLIENT_ID=作成したアプリケーションのクライアントID >> .env.development
echo COLORMESHOP_CLIENT_SECRET=作成したアプリケーションのクライアントシークレット >> .env.development
```

## 初回の起動

ライブラリのインストールやデータベースの準備を行い、起動します。

```bash
bin/setup
```

起動したら `http://localhost:8888` をブラウザで開いてください。

## 二回目以降の起動

```bash
docker-compose up
```

## ソースコードを更新したあとの起動

```bash
bin/setup
```

### テストを実行

```bash
docker-compose run --rm app bundle exec rspec -fd
```

## 動作確認

当アプリが利用しているスクリプトタグAPIで登録するURLはhttpsである必要があるため、実際に動作を確認する際は予め下記の設定を行ってください。

### ngrokのインストール/起動

[ngrok](https://ngrok.com/)をインストールし、下記コマンドで起動します。

```
/path/to/ngrok http 8888
```

### スクリプトタグAPIで登録するsrc属性を変更

ngrokを起動するとターミナルにURLが表示されますので、httpsから始まるURLで[設定ファイル](/config/settings/development.yml)を更新してください。

```diff
script_tag:
-  src: "https://localhost:8888/js/disable-right-click.js"
+  src: "https://{ngrokで作成されたアドレス}/js/disable-right-click.js"
```

※ ngrokの無料版は起動する度にアドレスが変更されます。無料版をお使いの方はお手数ですが、変更されるごとに上記の設定を変更してください。
