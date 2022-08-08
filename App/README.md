# PCK2022_Solimage

## 準備
1. Android Studio, Flutterの環境構築をする
   - Visual Studioは不要
   - ちょっと面倒ではあるけど日本語化もできる
   - 参考例: https://qiita.com/Toshiaki0315/items/adeb29caa4b63051b8ba#android-studio%E3%81%AE%E8%A8%AD%E5%AE%9A
2. Virtual Device ManagerでAndroid 11.0 (R)のPixel 4のエミュレータを作る
3. SDK Managerで以下2つをインストールする
   - Android 11.0 (R)
   - Android 12.0 (S)
4. リポジトリをクローンし、`dev`ブランチに切り替える
5. `App`フォルダーをAndroid Studioで開く
6. ターミナルから`flutter pub get`を実行して、パッケージをインストールする
7. ウィンドウ上部のFile->Project StructureからProject SDKをAndroid API 30 Platformに設定する

## ビルド
1. Fileの下に`<no device selected>`と表示されている場合、そこのOpen Android Emulator: Pixel 4 API 30からエミュレータを起動する
   - Pixel 4 API 30 (mobile)という表示に変わればOK
2. 実行ボタンを押し、しばらくするとエミュレータ上にアプリが立ち上がっていることを確認する
