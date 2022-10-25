# これは画像処理や推論をするソースのディレクトリです
## imageUtils
このクラスのメンバ関数は全て静的メンバです、インスタンスは作らずに関数を実行してください。

## Classfier
このクラスはtensorflow liteで推論をするためのクラスです。
singletonなのでインスタンスの作成はできません。
`preProcess`が画像のリサイズ等の前処理のみ、`predict`は前処理と推論がセットになった関数です。`predict`の返り値は`List<double>`でlabelIDをindexとした確率が入っています。
