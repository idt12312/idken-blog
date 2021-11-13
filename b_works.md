---
layout: page
title: Works
permalink: /works/
---
過去に作ったものたちです。


# 電子負荷
20V 10Aまで使える電子負荷です。

液晶に電圧電流測定値を表示し、スイッチとロータリーエンコーダで電流設定値を変更できます。
電力を消費するMOSFETをPC用CPUクーラーで冷やしているのが特徴です。

![](/images/eload.jpg){:data-action="zoom"}

[**電子負荷の紹介記事**](/posts/2021-11-13-eload/)


# ENBLE
BLE経由で温度湿度気圧データを収集する、いわゆる環境センサです。
コイン電池で1年以上動き続ける予定です。

![](/images/enble.jpg){:data-action="zoom"}

RaspberryPi3とThingsBoardをつかって家にばらまいたENBLEのデータを収集し、表示するシステムも作りました。

![](/images/enble_system.svg){:data-action="zoom"}

設計データや詳細はGithubで公開しています。

[**Github:idt12312/ENBLE**](https://github.com/idt12312/ENBLE)

[**ENBLEの紹介記事**](/posts/2019-04-20-enble/)


# Inou(開発中)
マイクロマウスハーフサイズ初挑戦です。
2018年度の大会はこれで出場し、全日本大会のエキスパートクラスセミファイナルに出場できました。

![](/images/inou.jpg){:data-action="zoom"}

Tofセンサ(正面、真横向きの計3つ)を使って壁との距離を計測し、自分の位置を計測できるのが特徴です。
1区画前の壁のあるなし判定や、壁切れを読むために斜め45度の赤外線センサは残してあります。
あと、MIZUHOv2に引き続きマイクが載せてあります。

現在2019年度の大会に向けて改良中です。

# KURAMOTO
蔵本モデルをLEDとマイコンを使って可視化した作品です。
基板を繋げるとLEDの発光パターンが同期していきます。   
MFT2017で展示をしていました。

![](/images/kuramoto.jpg){:data-action="zoom"}

紹介動画も作ってみました。

<div class="movie-wrap">
<iframe width="560" height="315" src="https://www.youtube.com/embed/wogfamjA1L0" frameborder="0" allowfullscreen></iframe>
</div>

[**KURAMOTOの紹介記事**](http://idken.net/posts/2017-08-02-kuramoto/)

何に使えるかと何度か聞かれたのですが、これはアートです。

# 電子マネーの残金チェッカー
suicaなどの電子マネーのカードをタッチすると、チャージされている金額を読み取って表示するデバイスです。

![](/images/charge_checker.jpg){:data-action="zoom"}

[**電子マネーの残金チェッカーの紹介記事**](http://idken.net/posts/2017-05-05-charge_checker/)

# マイクロマウス:MIZUHOv2
マイクロマウスの2017年度の大会に向けて製作していたクラシックサイズのマシンです。
以前作っていたMIZUHOの改良版です。

![](/images/mizuhov2_2017.jpg){:data-action="zoom"}

このマウスにはマイクが載っていて、オカリナで短いフレーズを吹くとコマンド入力ができるという機能を実装しました。
全日本大会ではなんとかエキスパートクラスの決勝に進むことができ、特別賞も頂けました。

[**MIZUHOv2の紹介記事**](/posts/2017-04-01-mizuhov2/)

[**全日本大会と2017年度のまとめ**](/posts/2017-12-03-mouse_2017/)


# B-ART
UARTをBLEを使って無線化するモジュールです。
4pinのピンヘッダがついているTypeP、USBでPCに挿せるTypeUの2Typeがあります。

![B-ART](/images/bart_overview1.jpg){:data-action="zoom"}

[**B-ARTの紹介記事**](http://idken.net/posts/2017-04-04-b-art/)

[**Github:idt12312/B-ART**](https://github.com/idt12312/B-ART)

# マイクロマウス:MIZUHO
第37回全日本マイクロマウス大会のクラシック競技フレッシュマンクラスに出場。
決勝に進出し、11位でした。

<img src="/images/mizuho.jpg"  data-action="zoom" style="width: 300px;">

基板データ・ファームウェアはこちら

[**Github:idt12312/MIZUHO**](https://github.com/idt12312/MIZUHO)

# 玉乗りロボット:2号機
前作1号機の進化版です。
オムニホイールを小さい1重のオムニホイールに変更し、全体的にスリムになっています。

<img src="/images/tamanori_robot_overview.png"  data-action="zoom" style="width: 300px;">

# マイクロマウス:探索アルゴリズム
友人がマイクロマウスの2015年度大会に出場するので、探索部分だけ手伝いました。
ソースは[Github](https://github.com/idt12312/MazeSolver2015)で公開しています。  

[**解説記事はこちら**](http://titech-ssr.blog.jp/archives/1046800312.html)

<div class="movie-wrap">
<iframe width="500" height="315" src="https://www.youtube.com/embed/V0p6QD187bI" frameborder="0" allowfullscreen></iframe>
</div>

# LEDで2048
MFT2015で展示。一時期流行ったパズルゲームです。
本体を傾けるとそちらの方向にパネルが移動します。  

[**LEDで2048の紹介記事**](http://titech-ssr.blog.jp/archives/1035638533.html)

![2048](/images/works_2048.jpg){:data-action="zoom"}

<div class="movie-wrap">
<iframe width="500" height="315" src="https://www.youtube.com/embed/0m8Ng94H8lQ" frameborder="0" allowfullscreen></iframe>
</div>

# 玉乗りロボット:1号機
バスケットボールの上で玉乗りをします。
youtubeで見た熊谷先生の玉乗りロボットに憧れて作りました。

* [**概要**](http://titech-ssr.blog.jp/archives/3739685.html)
* [**制御回路**](http://titech-ssr.blog.jp/archives/1000995129.html)
* [**機械工作**](http://titech-ssr.blog.jp/archives/1002230098.html)
* [**制御について**](http://titech-ssr.blog.jp/archives/1005228866.html)

![玉乗りロボット:1号機](/images/works_tamanori1.jpg){:data-action="zoom"}

<div class="movie-wrap">
<iframe width="500" height="315" src="https://www.youtube.com/embed/-Y_EpmI2GxY" frameborder="0" allowfullscreen></iframe>
</div>

# トランジスタ時計
MFT2014で展示。
NAND計をMFT2013で展示していたら「トランジスタでやらないんですか???」と言われたため、 サークルの後輩を含めた4人で製作しました。  
[**トランジスタ時計の紹介記事**](http://titech-ssr.blog.jp/archives/1018020218.html)

<img src="/images/works_trans.jpg" data-action="zoom" style="width: 400px;"> 

# Raspiミュージックサーバ
部室で稼働していました。
現在再生中の曲名をツイートもします。  
[**Raspiミュージックサーバの紹介記事1**](http://titech-ssr.blog.jp/archives/2236926.html)  
[**Raspiミュージックサーバの紹介記事2**](http://titech-ssr.blog.jp/archives/1018042125.html)  
![Raspiミュージックサーバ](/images/works_music_server.jpg){:data-action="zoom"}

# NAND計
MFT2013で展示。
いまのところ人生における最高傑作。
![NAND計1](/images/works_nand.jpg){:data-action="zoom"}
![NAND計2](/images/works_nand2.jpg){:data-action="zoom"}

# 秋月300円液晶MP3プレーヤー
初の発注基板作品。 とりあえず秋月液晶が使いたかった。  
SDカードからmp3データを読み込んで再生します。  
![MP3プレーヤー1](/images/works_mp3_1.jpg){:data-action="zoom"}
![MP3プレーヤー2](/images/works_mp3_2.jpg){:data-action="zoom"}

# フルカラーLED調光器
オペアンプだけでRGB3本のPWMを生成しています。  
つまみを回して色を調整可能。  
![フルカラーLED調光器1](/images/works_led1.jpg){:data-action="zoom"}
![フルカラーLED調光器2](/images/works_led2.jpg){:data-action="zoom"}

# TD4
みんなとりあえずつくるやつ。部品は鈴商で。
![TD4](/images/works_td4.jpg){:data-action="zoom"}

# ニキシー管時計
大学に入って最初に作った作品。
基板は感光基板。
![TD4](/images/works_nixie.jpg){:data-action="zoom"}

