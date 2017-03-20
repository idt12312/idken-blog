---
layout: post
title: Eclipse上でシリアルターミナルを使う
category: Eclipse
tag:
    - Eclipse
comments: true
thumb: http://git.eclipse.org/c/equinox/rt.equinox.framework.git/plain/features/org.eclipse.equinox.executable.feature/library/win32/eclipse.ico
---
Eclipse上でシリアルターミナルを動かす


# はじめに
マイコンの開発にEclipse(もしくはEclipse派生)を使用している方は多いと思います。
加えてマイコンの開発をする際にはデバッグのためにシリアル通信を用いることが多くあります。

私はIDEとは別にTeratermなどのターミナルソフトを別に立ち上げていたのですが、どうやら
そのターミナルもEclipse上で完結させることができるみたいです。

実際にやってみるとこんな感じになりました。

![](/images/eclipse_serial_term0.png)

それではこのようにEclipse上でシリアルターミナルを使用する方法を紹介したいと思います。

説明では以下の環境を想定しています。

* Windows 10 64bit
* JRE 64bit 1.8.0_121-b13
* Eclipse NEON.2 v4.6.2

Eclipse上でシリアルターミナルを使用する方法はググると色々出てきますが、
バージョンが古くてうまくいかなかったり、入れるべきpluginの名前が変わっていたので、
現段階で最新と思われるバージョンでの話を書いていきます。

### 参考にしたページ

* [ターミナル・プラグイン インストール(x64対応)](http://www48.atpages.jp/~cent22/Electronics/STM32/DevelopEnv/DSDP_Term/DSDP_Term.html)
* [Integrating a serial output window with Eclipse](https://github.com/theolind/mahm3lib/wiki/Integrating-a-serial-output-window-with-Eclipse)


# 必要な設定

## 手順1 ドライバ?のインストール
後でインストールするEclipse Pluginのため、ドライバのようなものをインストールします。
ここから実行環境のbit数に応じた"RXTXcomm.jar"と"rxtxSerial.dl"をダウンロードします。

[RXTX for Windows](http://jlog.org/rxtx-win.html)

リンク先にも書いてある通り、RXTXcomm.jarはjreのインストールされているディレクトリ内のlib\ext、
rxtxSerial.dlはjreのインストールディレクトリ内のbinにコピーします。
私の環境ではC:\\Program Files\Java\jre1.8.0_121\lib\extとC:\\Program Files\Java\jre1.8.0_121\binでした。


## 手順2 プラグインのインストール

### TM Terminal
Eclipseを起動し、上の方のメニューバーから[Help]->[Install New Software]を押します。
新たに出てきた画面の[Work with:]に

http://download.eclipse.org/releases/neon

を入力します。
EclipseのバージョンがNEONでない場合はURLの最後の部分を自分のバージョンにあった名前に変えれば後も同じようにできます。(たぶん)

しばらくするとpluginの選択肢が色々と出るので、
[Mobile and Device Development] -> [TM Terminal]を選択します。
(NEONでない場合は名前が変わっていて、"Target Management Terminal"や"TCF Terminal View"を選択します)

![](/images/eclipse_serial_install1.png)

[Next]を押すと色々表示されるので、確認しながらinstallを進めていきます。
Eclipseの再起動を求められ、再起動をしたら完了です。

### RXTX
先ほどと同様に、[Help]->[Install New Software]を押し、[Work with:]に

http://rxtx.qbang.org/eclipse

を入力します。

しばらくすると出てくるpluginの候補のうち、新しそうな方だけを選択し、installをします。

![](/images/eclipse_serial_install2.png)

同様にしばらく待つとEclipseの再起動を求められるので、再起動をしたら完了です。


# 動作確認
まず、シリアル通信のできるデバイスをPCにさし、COMポートがデバイスマネージャから見えるようにしておきます。

次にEclipseのメニューバーから[Window]->[Show View]->[Other]を押し、
出てきた画面から"Terminal"を探し、OKを押します。

<img src="/images/eclipse_serial_install3.png" style="width: 60%;">

するとEclipseの画面のどこかにTerminalが出てくるので、設定ボタンを押します。

![](/images/eclipse_serial_term1.png)

ここで通信の設定をします。

<img src="/images/eclipse_serial_config.png" style="width: 60%;">

OKを押すと接続されて通信ができるようになります。

赤い切断をするっぽいボタンを押すと通信を切断できます。

![](/images/eclipse_serial_term2.png)


# ちなみに
通信の設定をするところにSSHやTelnetなどの選択肢があるので、こちらを選択すればそれらの端末にもなります。
Local Terminalを選択すればコマンドプロンプトにつないりもできます。
