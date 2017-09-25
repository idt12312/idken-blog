---
layout: post
title: Fusion360と3Dプリンタを使う
category: Fusion360
tag:
    - Fusion360
comments: true
thumb: /images/thumb_pasta.png
---
Fusion360を使ってパスタメジャーを設計し、3Dプリンタで出力しました。


# Fusion360を使ってみる

最近何かと話題になっているFusion360を使ってみました。
今まではInventorを使っていたのですが、

* そこまで多くの機能を使っていない
* 学生である間しか無料で使えない
* 動作が重い
* インストール容量が大きい

という問題(?)がありました。

Fusion360は計算などはすべてサーバーで行われ、
クライアント側では絵の表示とユーザー入力をするのみです。
なのでインターネットに繋がっていないといけないのですが、
インストール容量は小さく、動作に必要なPCのスペックも高くはありません。


## モデリング

使ってみてわかったのですが、スケッチなどがInventorとほとんど一緒です。
Inventorはずっと使っていたので、すぐに使えるようになりました。

練習として何を作ろうかと考えた結果、パスタメジャーを作ることにしました。
[ここによると](http://kakublog.jp/mono/salus-measure/)
パスタメジャーの穴の直径は次の通りにすればいいみたいです。

* 1人前：22mm
* 2人前：30mm
* 3人前：38mm

Fusion360ではこんな感じになりました。

![](/images/pasta_fusion.png){:data-action="zoom"}


## レンダリング

Fusion360にはアニメーションやレンダリングをする機能も用意されています。
モデリング時にコンポーネントの素材や色を設定しておくとそれを元にレイトレーシングを行い、
実物と同じような見え方をシミュレートしてくれます。
計算はすべてサーバ側で行われるので、マシンスペックがあまりなくても問題なく、待っているだけでOKです。
待っている間にFusion360を終了してしまっても問題ありません。

素材を3Dプリンタで使用するABSの白に設定してレンダリングを実行するとこうなりました。

![](/images/pasta_render.png){:data-action="zoom"}

本物っぽい質感です。


## 共有機能を使ってみる

Fusion360ではデータもすべてサーバー上にあり、それ生かした共有機能が色々あります。
自分で作ったプロジェクトや3Dデータは[Autodesk360](https://myhub.autodesk360.com)からも見ることができ、
そこから共有の設定をすることができます。

共有の機能の一つで、Webページへ3Dモデルを埋め込む機能があります。
出力されたHTMLの埋め込みコードを使うと↓のようになります。

<div class="movie-wrap">
<iframe src="https://myhub.autodesk360.com/ue28e573b/shares/public/SH7f1edQT22b515c761ed320f0e5e34e7ddb?mode=embed" width="480" height="360" allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true"  frameborder="0"></iframe>
</div>

自分以外の人も3Dでぐるぐる回したりして見ることができます。


# 3Dプリンタで実体化する

3Dプリンタは部室のものを使いました。
データはSDカード渡すのですが、後輩がFlashAirをうまく使って
ネットワークに繋がっていさえすれば3Dプリンタにデータが送れるようになっています。

[部室3DプリンターのFlashAir化](http://titech-ssr.blog.jp/archives/1058326152.html)

出力中です。

![](/images/pasta_3d.jpg){:data-action="zoom"}

完成しました。

![](/images/pasta_output.jpg){:data-action="zoom"}


## 実際に使ってみる

パスタを計測します。

![](/images/pasta_hand.jpg){:data-action="zoom"}

パスタを茹でで、パスタソースをかけたら完成です。
パスタソースの自作は難しいのでレトルトのものを使いました。

![](/images/pasta_source.jpg){:data-action="zoom"}


# まとめ
Fusion360は簡単に使えることがわかりました。
さっそくマイクロマウスの機体の設計などに利用していきたいと思います。
