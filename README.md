# image-share

GitHub Pages を使った画像配布用リポジトリです。

## 送信側
1. `images/` に画像を置く
2. `scripts/build-manifest.ps1` を実行
3. commit / push

## 受信側
1. `scripts/receive-images.ps1` を定期実行
2. `manifest.json` を確認
3. 新着画像をダウンロード