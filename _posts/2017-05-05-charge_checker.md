---
layout: post
title: 電子マネーの残金チェッカー
category: 電子工作
tag:
    - 電子工作
    - pic
comments: true
thumb: /images/thumb_charge_checker.jpg
---
suicaなどの電子マネーカードにチャージされている金額を読み取って表示するデバイスを作りました。



# 概要
suicaなどの電子マネーのカードをタッチすると、チャージされている金額を読み取って表示するデバイスです。  
![](/images/charge_checker.jpg){:data-action="zoom"}

実際に動いていている動画はこちらになります。  

<div class="movie-wrap">
<iframe width="560" height="315" src="https://www.youtube.com/embed/NEz2cjugu6M" frameborder="0" allowfullscreen></iframe>
</div>

想定はしていませんでしたが、iPhoneのApple payもうまく動きました。
iPhone側にも残金が表示されているので、このデバイスが正しい値を表示していることが分かります。  
![](/images/charge_checker_apple.jpg){:data-action="zoom"}

# 構成

## 全体像
下の図のような部品を使用しています。  
![](/images/charge_checker_detail.png){:data-action="zoom"}


## FeliCaリーダライタ RC-S620S
今回の要になっている部品です。
Switch Scienceで売っています。  
[Switch Science: RC-S620S](https://www.switch-science.com/catalog/353/)

↑のモジュールはFFCのコネクタがついているだけで、
下記のものも買うとユニバーサル基板で使えるようになります。  
[Switch Science: ピッチ変換基板](https://www.switch-science.com/catalog/1029/)

RC-S620SとマイコンはUARTでデータのやり取りをします。
なのでRC-S620SのモジュールはUSRTのTXRXの2本、電源のVCCGNDの2本、合計4本を結線するだけで使うことができます。
電源は5Vでも3.3Vでもどちらでも動作可能です。

RC-S620Sは公式のArduinoのライブラリを使えば簡単に使うことができます。
今回はArduinoではなくPICを使ったので、このArduinoのライブラリを改変して使用しました。  
[SONY Arduino向けRC-S620/S制御ライブラリ](http://blog.felicalauncher.com/sdk_for_air/?page_id=2699)


具体的なSuicaへのアクセスは下記ページを参考にさせていただきました。  
[ORBIT SPACE: ArduinoでRELET（FeliCa電子マネー残高照会機）モドキを作ろう](http://www.orsx.net/archives/3835)


## マイコン PIC18F27J53
今回はPIC18F27J53を使用しました。
電源電圧は3.3Vで、内部クロックを使用して動かしています。

PIC18F27J53は非常に多くの機能を持ちながら、秋月で270円で買えるのでよく使っています。
PIC18F27J53はこちらでも紹介されています。  
[KERI's Lab : PIC18F27J53のすすめ](http://kerikeri.top/posts/2016-01-08-pic18f27j53/)


## 表示部分 7セグLED
7セグのLED達はダイナミック点灯で数字を表示をしています。
7セグLEDはアノードコモンなので、LEDのアノード側はNPNトランジスタでONOFFし、
カソード側をトランジスタアレイ(シンクドライバ)でONOFFしています。

一桁分の回路はこんな感じになっています。  
![](/images/charge_checker_led_digit.png){:data-action="zoom"}

使用した7セグLEDの順方向電圧が5Vくらいあったので、ACアダプタの出力電圧である9Vを
LEDのアノード側に印加しています。
PNPトランジスタを使ってLEDに電流を流すか流さないかを制御しています。
このPNPトランジスタをOFFにするためにはベースを9V、ONにするには8Vくらい以下にしないといけないので、
3.3VのマイコンではPNPトランジスタを駆動できません。
なのでNPNトランジスタを追加しています。

LEDのカソード側の回路は下図のようになっています。  
![](/images/charge_checker_led_overview.png){:data-action="zoom"}

TD62003というトランジスタアレイを使用しています。
これは入力側に01を入力すると出力側に入っているNPNのダーリントントランジスタがONOFFします。
なので電流をせき止めるor吸い込むの制御ができます。(これをシンクドライバというらしい)


# おわりに
思ったよりも簡単にできてしまいました。
気が向いたらケースを作りたいです。

