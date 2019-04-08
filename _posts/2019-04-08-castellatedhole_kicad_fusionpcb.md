---
layout: post
title: KiCad + FusionPCBで端面スルーホールを作る
category: KiCad
tag:
    - KiCad
    - マイクロマウス
comments: true
thumb: /images/thumb_castellated_hole.jpg
---
KiCad + FusionPCBで端面スルーホールを作ることができました。
簡単にESP-WROOM-32の基板のような端子が作れます。


# はじめに
この記事では[ESP-WROOM-32](http://akizukidenshi.com/catalog/g/gM-11647/)の基板の端にある端子と同じものを作る方法を紹介します。

![](http://akizukidenshi.com/img/goods/L/M-11647.jpg)
※画像は[秋月電子通商のサイト]((http://akizukidenshi.com/catalog/g/gM-11647/))から引用しています。

このパッドは端面スルーホール(英語ではPlated Half-holeやCastellated Hole)と呼ばれています。
この端面スルーホールをKiCad + [FusionPCB](https://www.seeedstudio.com/fusion_pcb.html)(Seed studioのPCB試作サービス)で作ることができたので、
その方法を紹介します。

この記事はKiCadの話しかしませんが、
たぶんEagleなどの他の基板CADでも同じようなデータを作れたら同じように製造されるはずです。
ただ未確認です。

# つくっていく
## KiCadでデータをつくる
SeedStudioのページにどうやってデータを作ったらいいかが書いてありました。
いつも通りにスルーホールの穴を配置し、基板外形線がスルーホールの中心を横切っていればいいみたいです。

[**SeedStudio: What are Plated Half-Holes/Castellated Holes?**](http://support.seeedstudio.com/knowledgebase/articles/910767-what-is-half-cut-castellated-holes)

KiCadでは次のようなデータを作りました。
ポイントは端面スルーホールにしたいスルーホールの中心を基板外形線が通っていることです。

![](/images/castellated_hole_kicad_omote.png){:data-action="zoom"}

スルーホール上に外形線をひくと、KiCadのオンラインDRCによってスルーホールまでTraceを伸ばせなくなってしまいました。
基板の縁とTraceの間のClearanceが必要なためです。
あまり綺麗な方法ではありませんが、私はGraphic polygonを銅レイヤーのオプジェクトとして配置をし、
このpolygonを介してスルーホールとTraceを電気的に接続しました。

端面スルーホール近くはレジストマスクを配置し、スルーホール部分以外も銅箔を露出させて半田付けをしやすくしてみました(必要ないかも)。

裏面も表面と同じように銅のpolygonとレジストマスクを配置しました。

![](/images/castellated_hole_kicad_ura.png){:data-action="zoom"}

この状態で3D表示をするとこんな感じに見えます。

![](/images/castellated_hole_kicad3d_omote.png){:data-action="zoom"}

スルーホールの半分が基板外形からはみ出でいますが、これで大丈夫です。
レジストマスクを設定した部分はちゃんとレジストがなくなっています。

裏面もこんな感じになっています。

![](/images/castellated_hole_kicad3d_ura.png){:data-action="zoom"}


## FusionPCBで注文をする
[FusionPCBの注文ページ](https://www.seeedstudio.com/fusion_pcb.html)に「Plated Half-holes / Castellated Holes」というオプションがあります。
これを有効にして注文すればOKです。

![](/images/castellated_hole_fusionpcb.png){:data-action="zoom"}

適切にデータを作った状態でこのオプションを有効にすると端面スルーホールが綺麗にできます。
ただし、追加料金はかかってしまいます。
このフォームからの注文以外に、特に製造上の指示をしなくてもちゃんと作ってくれました。

## 完成したもの

これは上記の方法でデータをつくり、FusionPCBで製造してもらった基板です。

![](/images/castellated_hole_pcb1.jpg){:data-action="zoom"}

綺麗に端面スルーホールができています。

![](/images/castellated_hole_pcb2.jpg){:data-action="zoom"}


### マイクロマウスに使う
今回端面スルーホールを作ったのは、マイクロマウスの機体でこんな感じで基板を立てたかったからです。

![](/images/castellated_hole_pcb3.jpg){:data-action="zoom"}

半田だけで止めるので力をかけたらもげそうですが、端面スルーホールなしで半田をもって基板を立てるのよりはしっかりとくっついてくれそうです。
そしてなによりも半田付けが簡単そうです。

# おわりに
要約すると、KiCad + FsuinPCBで端面スルーホールを作る場合は次の２つのことをすればOKです。

1. KiCadでスルーホールの中心を通るように基板外形線を引く
2. FusionPCBの注文時に端面スルーホールのオプションを指定する

端面スルーホールを使うことでESP-WROOM-32みたいに表面実装して接続できる基板が趣味でも作れそうです。
また、USB メモリのようなtypeAオスのプラグと一体になった基板を作るときにも使えそうです。

私は以前USB type Aと一体になった基板を作ろうとしたとき、端面スルーホールの指定をちゃんとしなかったので微妙な感じになりました。

[**B-ART：UARTをBLEで無線化するモジュール**](/posts/2017-04-04-b-art)

注文時にちゃんと確認をすればよかったですね。

自分はまだやってことありませんが、[Elecrow](https://www.elecrow.com/pcb-manufacturing.html)の注文画面にも端面スルーホールが作れそうなオプションがありました。
詳細は確認していませんが多分同じようなことをやればできるのでしょう。

![](/images/castellated_hole_elecrow.png){:data-action="zoom"}

