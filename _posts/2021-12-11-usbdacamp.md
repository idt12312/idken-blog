---
layout: post
title: USB-DAC付きオーディオアンプを作る
category: 電子工作
tag:
    - STM32
comments: true
thumb: /images/thumb_usb_dac_amp.jpg
---
USB接続のDAC付きオーディオアンプを作りました。
いい感じにできたので普段から使っています。


* A markdown unordered list which will be replaced with the ToC, excluding the "Contents header" from above
{:toc}

# はじめに
いいスピーカーを入手したので、音を出すためにUSB接続のDAC付きオーディオアンプを作りました。
音源の入力はUSB (USB Audio class 1.0) で、2ch 96kHz 24bitまで対応しています。
負荷8Ohmで5W x2chくらい出力できます。

![](/images/usb_dac_amp_1.jpg){:data-action="zoom"}

ケースはタカチのHIT18-4-13SSを使いました。
このケースの両サイドはヒートシンクになっていて、発熱する部品の放熱に利用しています。

背面には電源用のコンセント入力とスピーカー出力のバナナ端子があります。

![](/images/usb_dac_amp_2.jpg){:data-action="zoom"}

蓋を開けるとこんな感じになっています。

![](/images/usb_dac_amp_3.jpg){:data-action="zoom"}

ケース加工のための穴位置や、基板上の部品位置の確認のためにFusion360を使いました。
Fusion360での3Dモデルは以下のビュワーから見られます。

<iframe src="https://myhub.autodesk360.com/ue28e573b/shares/public/SH9285eQTcf875d3c53996d7cb9836263f28?mode=embed" width="640" height="480" allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true"  frameborder="0"></iframe>


この記事ではこのアンプの中身について紹介していきます。

# 全体構成

回路は以下の図のような構成になっています。

![](/images/usb_dac_amp_block_diagram.svg){:data-action="zoom"}

マイコンはUSBから音データを受け取り、I2SでDACにデータを流します。
DACは電流出力なので、I/V変換回路で電流を電圧に変換しています。
ボリュームはケースの前面に取り付けた2CHの可変抵抗で、I/V変換回路の出力電圧を分圧して音量を調整します。
パワーアンプではスピーカーを駆動するための増幅を行います。

パワーアンプの先には出力をON/OFFするリレーがあり、マイコンの制御により以下の動作をします。

* ポップノイズを防ぐために、電源ONから数秒してからリレーをONにする
* 温度センサーで異常過熱を検出したらOFFにする
* 電流制限回路作動して過電流が流れているときにOFFにする

全体の回路図は以下のリンクから見ることができます。

[**USB DAC AMP: 回路図**](/data/usb_dac_amp.pdf)

以降では回路、ソフト、外装の詳細についてを紹介していきます。

# DAC、IV Converter

DACはPCM1794Aを使っています。
このDACは差動電流出力のDACなので、パワーアンプに電圧を入力するために、IV変換回路で差動電流をGND基準の電圧に変換しています。

IV変換回路として以下の回路を使っています。

![](/images/usb_dac_amp_iv.svg){:data-action="zoom"}

U401の二つのopampで差動電流をそれぞれ電圧に変換し、後のU402で差動からGNDA基準に変換しています。
GNDAはスピーカーの出力付近からスター配線をしている配線で、GNDにつながっています。

このIV変換回路によって-6.2mAを中心に+-3.9mAの振幅を持つ電流がGND基準の+-8.3Vになります。
IV変換回路の帯域は60kHzくらいあります。

# アンプ

左右のスピーカーのためにある2CHのパワーアンプは以下のような回路です。

![](/images/usb_dac_amp_pa.svg){:data-action="zoom"}

ゲインは1.5倍で、帯域は400kHzくらいあります。

DAC出力につながるI/V変換回路でフルスケール+-8.3Vの信号が得られるので、パワーアンプのゲインは必要ありません。
一応電源電圧くらいまで出力電圧を振れるように、パワーアンプのゲインはx1.5に設定しました。

後述するバンドパスフィルタのために高インピーダンスで受けたかったので、非反転増幅回路の構成にしています。
人間に聞こえる音は20kHzくらいなので入出力の帯域は20kHzくらいで十分ですが、20kHzくらいでも十分に外乱抑制をするために帯域は20kHzよりも広くとってあります。

一般的な電圧増幅アンプの入力段とゲイン段としての役割は、出来合いのopampであるOPA1612に任せています。
このopampから先の、電流を増幅するバッファをディスクリート部品で作っています。
バッファ回路はよくあるダーリントン接続をしたエミッタフォロワとバイアス回路で構成されます。

出力段のQ705, Q706は発熱をするので、基板に実装せずにケースのヒートシンクにねじ止めしています。
Q702は出力段のバイアス電圧を作って、出力段の熱暴走を防ぐためにQ705、Q706と同じくヒートシンクに固定しています。よくある温度補償です。

スピーカーはパワーアンプと直結するので、何かの間違いでパワーアンプがDC電圧を出力するとスピーカーが壊れます。
これを防ぐためにパワーアンプの入力の手前に0.22Hz ~ 160kHzの1次のバンドパスフィルタが入れてあります。

![](/images/usb_dac_amp_pa_bpf.svg){:data-action="zoom"}

回路を設計し始めるときに、マイコンのソフトの開発時やソフトのバグにより、DACがDCで電圧を出力してしまうことがあるだろうなと思いました。
こんなときでもパワーアンプがDC電圧を出力しないように、DAC出力のDC成分をカットしてからパワーアンプに入力しています。

インターネットを見ているとパワーアンプの出力と直列にコンデンサを入れている例もあります。
この方法だとパワーアンプが故障してDCを出力してしまった場合も対策することができます。
しかし低周波まで通過させようとすると非常に容量の大きなコンデンサが必要になってしまうので今回は採用しませんでした。
パワーアンプ単体で壊れてDCを出力しないことを祈ります。

# 電源

ブロック図にあるように、電源の大元はACコンセント入力です。
市販の絶縁AC/DCで+-15Vを作り、電流制限回路を通してからアンプ用にリニアレギュレータで+-12Vを作っています。
このリニアレギュレータはBJTとopampを使ってディスクリートで組んでいます。

## リニアレギュレータ

+15Vのリニアレギュレータの回路は以下の通りです。
-15V、+5Vも同じような回路で作っています。

![](/images/usb_dac_amp_linreg.svg){:data-action="zoom"}

電源の帯域は出力電流によって変化しますが、40~100kHzくらいになっています。

リニアレギュレータの出力にはESRの低いOS-CONを使っています。
電源ラインには十分にESRの低いコンデンサがつくことをあてにしてリニアレギュレータの制御系を設計しているので、
コンデンサの値を変えたりESRの大きい電解コンデンサを使うと発振します。

出力電流によって帯域が変化するのは、エミッタフォロワとして動作しているBJTの出力抵抗が流れる電流によって変化してしまうからです。
出力抵抗と負荷の容量によって遅れが発生し、その遅れ具合が出力電流によって変化するので制御系の1巡伝達のゼロ交差周波数も変化します。
今回は負荷の定常的な消費電流が分かっているので、その最低値以上は電流が流れるものとして設計しました。

### 市販レギュレータの疑問
この回路を作ってみて、広い負荷電流範囲で発振しない市販のリニアレギュレータICはどういう設計になっているのか気になりました。

例えば低消費電力のためにバイアス電流を流すことが許されず、Sleep状態とActive状態でuAとmAと100倍以上の電流の振れ幅があるような回路の電源(リニアレギュレータ)を考えます。
電源の出力部分のBJTの出力抵抗は100倍(MOSFETなら10倍)以上変化することになります。
負荷がマイコンならたいていESRの低いセラミックコンデンサがたくさんつながっているのでESRによる零点は期待できず、出力抵抗と負荷容量による極が100倍や10倍のオーダーで変化することになります。

想定される全ての状況で安定になるように制御方法を頑張るのか、出力の回路を工夫するのか、気になります。

## 電流制限回路

回路が壊れずにちゃんと動いていても、スピーカーの出力端子を間違ってショートすると回路に大電流が流れて壊れてしまいます。
スピーカーの出力端子は+-間が近く、金属片で簡単にショートできてしまうので何か対策をしておきたいです。

今回はパワーアンプの電源に電流を制限する回路を入れて、電流が流れすぎないように対策をしました。

電流を制限する回路は以下のような回路です。
これは+15Vラインに使っている回路で、同じような回路が-15Vラインにもついています。

![](/images/usb_dac_amp_ilim.svg){:data-action="zoom"}

R309が電流センス抵抗で、この抵抗での電圧降下が0.6Vくらいになる電流が流れるとQ301がONし始めます。
これによりQ303のVgsが小さくなり、Q303のVdsが大きくなる代わりにIdが一定値になります。
結果的にある一定以上の電流が流れない電流制限が実現できます。

電流制限が効いているとき、MOS FETはリニア動作をしているので Vds * Id の電力消費をします。
Q303は定常的にこの電力を消費させると発熱で壊れますが、後述するように電流制限が働くとすぐにアンプの出力リレーを遮断するので問題はありません。
ms以下くらいの電流制限はこの電流制限回路で行い、それより長い時間での保護はマイコンとリレーで実現しています。

電流制限が働いているときはアンプ出力がショートされたり異常事態が起こっている状態なので、いち早く出力を遮断したいです。
なのでU302のコンパレータを使ってマイコンに電流制限が働いていることを通知し、マイコンが出力リレーをOFFします。
電流制限が働くとQ303のゲート電圧が高くなるので、それが7.5V以上になったかどうかをコンパレータで判定することで電流制限が働いたことを検出できます。

コンパレータはオープンドレイン出力なので、+15V側と-15V側をwired or して一つの過電流信号としてマイコンに入力しています。
マイコンではSTM32のEXTI割り込みを使ってこの異常事態を処理します。

意図的に+15V電源をショートして、電流制限がうまく働くかをテストした時のオシロで見た各部の波形は以下の通りです。

![](/images/usb_dac_amp_scope_ilim1.svg){:data-action="zoom"}

スイッチを使って+15V電源を1Ohm (パワーアンプのエミッタ抵抗に相当) を介してGNDにショートしています。
+15V電源から流れ出た電流は1Ohm抵抗の両端電圧から換算しています。
オシロの設定で1V=1Aに変換して表示する機能があったので、電流値として表示しています。

ショート中は電流がちゃんと1.3Aに制限され、マイコンに入力される過電流信号がHigh→Lowになっていることが確認できました。

### 失敗したこと

実は電流制限回路では設計を失敗している部分があります。
それは、電流制限回路の後に大きな容量を入れてしまったことです。

先ほどのオシロの波形は横軸が20ms/divと広めにとっていたのでうまく動いているように見えていました。
100us/divで見ると、以下のように1.3Aをはるかに超える大きな電流が数百usの間流れてしまっています。

![](/images/usb_dac_amp_scope_ilim2.svg){:data-action="zoom"}

これは容量に充電されていた電荷が電流制限回路を通らずに一気に流れ出てしまっているためです。
ピークの12Aは {15Vくらい} / {1Ohm} から決まっている電流値だと思います。
電流は時定数100usくらいで減衰していき、最終的には設計値の1.3Aに収束していきます。
時定数100usは1Ohmと100uFから決まっている値です。

パワーアンプの出力段のトランジスタに15Vの電圧とこの電流が流れると壊れる可能性もあります。
実際に音楽を再生しながらアンプの出力をショートさせると、出力段のトランジスタは壊れることなく一瞬耐え、マイコンの制御によりリレーが遮断されて保護されます。
おそらく実使用条件だとアンプの出力電圧がそこまで高くないので、壊れずに耐えているのだと思います。

次作るときは、電源に電流制限回路を入れるなら容量の後ろに入れるか、パワーアンプの出力段のBJTを使って電流制限する構成にしたいです。

## スイッチング電源のノイズ対策

AC/DCはMean WellのIRM-20-15を使いました。
しょうがないことではありますが、無視できないくらい放射ノイズがあります。

少なくとも静電性を対策し、誘導性のノイズも軽減されることを期待して銅箔テープで電源モジュールを覆いました。
基板上では表面にGNDパターンをおいているため、雰囲気6面シールドになっています。

![](/images/usb_dac_amp_shield.jpg){:data-action="zoom"}


この対策によって、電源の放射ノイズはアンプ回路においてオシロでは見えないくらい小さくなりました。


# マイコンでやっていること

マイコンには以下のような機能を実装しています。

* USB-I2S
* 過電流保護
* 過熱保護
* リレーON遅延
* デバッグ用シェル

これらの機能はお互いに優先度を持ちつつも同時に動いていて欲しいので、
[FreeRTOS](https://aws.amazon.com/jp/freertos/)を使って各機能を一つのタスクとして実装しました。

以降ではそれぞれの機能について紹介します。

### USB-I2S

ST microがサンプルとして公開している、[X-CUBE-USB-AUDIO](https://www.st.com/ja/embedded-software/x-cube-usb-audio.html)を使いました。
USB Audio Class 1.0に対応していて、24bit 96kHz 2chまでのデータを再生できます。
DACとの接続部分が自分の回路に変更しやすくなっているので、今回も簡単に移植できました。

X-CUBE-USB-AUDIOはAudio CLass の非同期 (Asynchronus) モードに対応した実装になっています。
このおかげでDACに送るI2SのクロックはPCやUSBのタイミングに影響されずに、マイコン側の発振器で自由に決められます。

マイコンから見たときに、USBから流れてくるデータとDACに流すデータが非同期だといつかマイコン内のバッファが溢れます。
この問題を防ぐために、非同期モードではマイコンからPCに定期的にフィードバックと呼ばれる、一定時間内にいくつのデータを消費できたかを通知します。
PC側はフィードバックの内容に応じて送り出すデータ量を調整し、マイコン内部のバッファが溢れないように制御します。

gccのオプションを-O0でビルドすると、24bit時は48kHzまでしか正常に再生できませんでした。
96kHzにするとマイコンの処理が間に合わず、音がぶつぶつ途切れます。

-O2でビルドすると24bit 96kHzでも問題ありません。
どうやら24bitのデータをI2SでDACに送る用に、32bitにパディングする部分に時間がかかっているようです。

### 過電流保護

電流制限回路のところで紹介したように、電流制限が作動するとコンパレータの出力がLowになります。
この信号をSTM32のEXTIで検出して割り込みを起こします。
割り込みを受けて、マイコンはDACの出力を0Vに設定し、リレーをOFFにします。

この処理を行うタスクの優先度は一番高くしてあるので、割り込みから低いレイテンシで保護処理が走ります。

### 過熱保護

両側のヒートシンクと基板上の合計3箇所に温度センサーを実装しています。
温度センサーICはアナログ出力のLMT87を使っています。
ICを小さい基板に実装し、基板をヒートシンクにねじ止めをすることでヒートシンクの温度を測定しています。

![](/images/usb_dac_amp_temp_sensor.jpg){:data-action="zoom"}

マイコンでは1秒に一回AD変換をして温度を測定値、どれかの温度センサーがある閾値以上の温度を示したら出力リレーを遮断します。

### リレーON遅延

電源ONしてすぐに出力リレーをONせず、1秒待ってからリレーをONしています。

電源投入と同時に出力リレーをONすると、DACやパワーアンプなどの出力がまだ落ち着いていないときにスピーカーが接続されてしまうので、
スピーカーからボッという音が聞こえます。これをポップノイズというらしいです。

音が嫌なのと、スピーカーを痛める可能性もあるのでリレーのONを遅延させることで対策しています。


### デバッグ用シェル

マイコンのプログラムを作るときにデバッグ用のシェルとして
[microshell](https://cubeatsystems.com/microshell/index.html)を使いました。
UARTを使ってPC上のターミナルからコマンドを送って操作できるようになります。

microshellは文字列を受け取り、文字列を解釈して事前に登録した関数を実行してくれます。
初期化時にコマンドである文字列と関数を紐づけたものをmicroshellに登録しておきます。

マイコンではFreeRTOSのタスクを一つ割り当てています。
このタスクではUART入力を待ち受け、UARTでデータを受信したらそれをmicroshellに渡し、コマンドを実行しています。

以下の画像はstatコマンドをtask引数付きで実行し、マイコンで動いているタスクの状況を表示している様子です。

<img src="/images/usb_dac_amp_shell.png" data-action="zoom" style="width: 60%;">

見切れていしまっていますが、stat kernelを実行するとFreeRTOS自体の情報を表示できます(そう実装しました)。

このほかにも、温度センサーや過電流検出の状態を表示するコマンドや、DACやリレーを直接操作するコマンドを作りました。
このおかげでデバッグ作業がいくらか楽になりました。

# ケース

ケースはタカチのHIT18-4-13SSを使いました。
アルミで加工しやすく、両サイドにヒートシンクがついているのがポイントです。

このケースに手作業で頑張って加工をしました。
四角い穴はハンド二ブラで開けていますが、いまだにきれいに加工ができないです。

![](/images/usb_dac_amp_chassis.jpg){:data-action="zoom"}

ヒートシンクにはドリルで穴を開けた後、タップを使ってねじ穴を切っています。
これによって放熱したいトランジスタを直接ねじ止めできています。



# おわりに

動作に問題はなく、見た目も気に入っているので、このアンプを作って以来日常的に使っています。

いい感じにできたので、以下の点を改良した版を作っていきたいです。

* 電流制限回路を意味のある形で実装する
* USBを Audio Class 2.0に対応させる
* Bluetoothでもつながるようにする

既にBluetoothでつなげる部分はMicrochipのBM83を使ってなんとなくできました。
冒頭のブロック図のDACの手前にあったMUXはコネクタを介して外部のI2S入力を受け付けるためのもので、
ここにBM83を繋げています。

![](/images/usb_dac_amp_bluetooth.jpg){:data-action="zoom"}

より使いやすいものになるといいですね。