# PCK2022_Solimage

## ブランチやcommitのルール
- `main`と`dev`ブランチをベースとする

- 開発は`dev`から新しく分岐させたブランチを作り、一つの作業毎(複数のcommitがあっても良い)に`dev`にPRしてください
  - 分岐させるブランチは`dev-<作業内容(アルファベット)>`で作ってください
  - PRのタイトルは作業内容がわかるような簡潔なものにしてください
  - 使い終わったブランチは消してください

- commitのコメントには作業の概要がわかるよう、commit種別を付けるようにしてください

  |commit種別|内容|
  |-|-|
  |fix|バグ修正|
  |hotfix|クリティカルなバグ修正|
  |add|新規（ファイル）機能追加|
  |update|機能修正（バグではない）|
  |change|仕様変更|
  |clean|整理（リファクタリング等）|
  |disable|無効化（コメントアウト等）|
  |remove|削除（ファイル）|
  |upgrade|バージョンアップ|
  |revert|変更取り消し|

- `dev`でバグが無いと判断できたら`main`にPRしてください

- Releaseできるのは`main`のみとします

## ディレクトリ構成

```
/
├App/
│ └<Flutter Project>
│
├Backend/
│  └<Backend Project>
│
└README.md
```

## 機械学習

学習に用いる画像はgoogle driveやonedriveなどに保存してください

機械学習モデルはAppディレクトリ内の適当な場所に置いてください