---
layout: post
title: J-Linkで仮想シリアルポートを使う
category: マイコン
tag:
    - マイコン
    - ARM
    - J-Link
comments: true
thumb: /images/thumb_jlink.png
---
J-Linkには仮想シリアルポートになる機能があることを知りました。
その使い方を紹介したいと思います。

# はじめに
J-Linkとは、以前もブログで紹介していた便利なマイコン用デバッガです。

<img src="https://www.segger.com/fileadmin/images/products/J-Link/J-Link_EDU_shadow_500.png"  data-action="zoom" style="width: 200px;">

[**id研：超便利 最強デバッガ J-Link**](http://idken.net/posts/2017-08-31-jlink/)

主な機能や入手方法、手持ちのNucleoなどについているST-LinkをJ-Link化する方法については↑の記事をご覧ください。
対応しているマイコンが多く(ARM Cortex A,M,R / Microchip PIC32 / Renesas RX)、便利機能が色々とあります。
最近、このJ-Linkに仮想シリアルポートになる機能があることを知りました。
J-LinkのあるピンがUARTのTXとRXのピンになり、PCとマイコンでシリアル通信ができるという感じです。
もちろんデバッガとしての機能と併用可能です。

この記事ではJ-Linkを仮想シリアルポートとして使うための設定方法と、実際の使い方について紹介します。
以降の内容はJ-Link EDUとnucleoをJ-Link-OB化したもので動作確認はできています。
J-Link EDUでできたので、純正J-Link(BASEやPRO)でもできるでしょう。
他のボードをJ-Link OB化したものでできるかは不明です。
**J-Link Lite CortexMではできませんでした。**

# J-Linkの設定
J-LinkでもJ-Link OBでも同じ用に設定できます。
デフォルトでは仮想シリアルポートとしての機能はOFFになっているので、
J-Linkを使うためのツールからこの機能をONにする必要があります。
GUI(Windowsだけ?)からでも、コマンドラインからでも設定できます。

## GUIからの設定
J-Link Configuratorを起動します。
接続されているJ-Linkのデバイスが表示されるので、
設定したいデバイスをダブルクリックするとこんな画面が出ます。

![](/images/jlink_serial_config.png){:data-action="zoom"}

「Virtual COM-Port」の設定をEnableにすると設定完了です。


## コマンドラインからの設定
JlinkExeやJ-Link Commanderからコマンドを打って設定できます。

```
J-Link>vcom enable
The new configuration applies after power cycling the debug probe.
J-Link>
```

(このコマンド、JLinkExeのhelpには出てこないんですよね～)

## 動作確認
一旦J-Linkの繋がっているUSBケーブルをPCから抜いてまた挿します。
そうすると仮想シリアルポートとして認識されるはずです。

![](/images/jlink_serial_device.png){:data-action="zoom"}

# 使い方
PC側にはシリアルポートとして認識されているので、
よくあるUSB-シリアル変換モジュールを使うときと同様にシリアルターミナルから接続するだけです。

## ピン配置
### J-Link
色をつけた部分がUARTのRXとTXのピンです。

![](/images/jlink_serial_pinout.png){:data-action="zoom"}

※画像はJ-Linkのマニュアルを改変


### J-Link OB 化したnucleo
同様に色をつけた部分がUARTのRXとTXのピンです。

![](/images/jlink_serial_nucleo.jpg){:data-action="zoom"}

これはデフォルトのST-Link v2.1で仮想シリアルポートとなっているピンです。
J-Link OB化してもちゃんとその機能は使えるということです。


# おわりに
J-Linkはちゃんとシリアル通信も使えたんですね。

話は変わりますが、J-Link EDU MiniがDigikeyから買えるみたいです。
今回紹介したシリアル通信の機能が使えるかは分かりませんが、
小さくて安いので良さそうです。(私はまだ買っていません)

[**Digikey: J-Link EDU Mini**](https://www.digikey.jp/product-detail/ja/segger-microcontroller-systems/8.08.91-J-LINK-EDU-MINI/899-1061-ND/7387472)

