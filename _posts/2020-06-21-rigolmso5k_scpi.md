---
layout: post
title: RIGOL MSO5000 OscilloscopeをPythonから制御する
category: 電子工作
tag:
    - 電子工作
    - Python
comments: true
thumb: /images/thumb_rigol5k_photo.jpg
---
RIGOLのMSO5000シリーズのオシロをPythonから制御した例を紹介します。



# はじめに

## 作ったもの

Pythonを使ってMSO5000を制御するスクリプトを作ってみました。思ったより記事が長くなったので成果物だけをここに挙げておきます。

* オシロのスクリーンキャプチャを画像データとして保存する
    [Gist idt12312/load_screen.py](https://gist.github.com/idt12312/98f52c0b524b9cc5fbda9dfd84a3f421)
* オシロで取得した波形データをcsvファイルとして保存する
    [Gist idt12312/save_as_csv.py](https://gist.github.com/idt12312/a9d9a600a100b7d0ad121114d1d4cf5d)


## オシロを買った
最近RIGOLのMSO5000シリーズのオシロ(RIGOLの黒いオシロと言われているような)を買いました。
値段の割に高機能で、趣味で電子回路をいじる分には十分な性能です。

![](/images/rigol5k_photo.jpg){:data-action="zoom"}


## プログラムから操作したい

オシロをはじめとする計測器にはPCのプログラムから自動制御できるような機能がたいてい実装されています。
このRIGOL MXO5000のオシロも例の漏れずそうです。
多くの測定パラメータで何回も似たような測定をしたい場合には、プログラムを作って自動で測定をした方が楽です。
例えば工場の出荷試験などがそうでしょう。

趣味用途ではどうでしょうか。
主に回路の動作確認やデバッグのために使われることが多く、いちいちプログラムを作って測るよりも手動でオシロのボタンやつまみをいじって操作する方が便利です。
よくわからない動作を追うので測定パラメータを事前に決めることは難しいですし、一回限りの測定であるこも多く、わざわざプログラムを作っていては無駄が多いでしょう。
なので趣味用とオシロをプログラムから操作する必要性はあまりないのかもしれません。

趣味用途でもプログラムからオシロを制御できて嬉しい場面はないかと考えた結果、
スクリーンキャプチャと波形データをPCに読みだす機能だけはプログラムから(というかPCから)操作できると便利かなと思いました。
手動では、USBメモリをオシロにさしてボタン操作をすることでUSBメモリにスクリーンキャプチャや波形データを保存することができます。
保存のたびにオシロのメニューを切り替える必要があり、何度もデータを取ろうと思うと煩わしく感じることもあります。

この記事ではPythonを使って

* スクリーンキャプチャを画像データとして保存する
* 波形データをcsvファイルに保存する

というのをゴールにして、PythonからRIGOL MSO5000シリーズオシロを制御する方法を紹介したいと思います。
計測器の操作はメーカーや計測器の種類によらずある程度抽象化されているので、
他の計測器をPythonから制御したい場合にも役に立つのではないかと思います。


## VISAとSCPI

計測器の制御の規格を統一するたに、IVI FoundationがVISA(Virtual Instrument Software Architecture)というAPI規格を定めています。
VISAはハードウェア操作を抽象化するので、VISAに準拠している計測器であればメーカー・機種・インターフェースが違っても同じように制御できます。

![](/images/rigol5k_visa.svg){:data-action="zoom"}

RIGOLのオシロもVISAに準拠をしているので、世の中にあるVISAに準拠した測定器の制御方法が通用します。

VISAの上でデータや命令をやり取りするコマンドとしてSCPI(Standard Commands for Programmable Instruments)というものがあります。
SCPIではコマンドの構文とデータの送受方法が共通化されているだけで、コマンド自体は計測器によって独自のものが定義されています。
現代の多くの計測器はSCPIで動くので、SCPIを使えば具体的なコマンドは違えど同じような考え方で制御をすることができます。
SCPIは文字列で構成されるコマンドなので、プログラミング言語によらず同じコマンドで制御をすることができます。

SCPIが定まる以前に作られた計測器は、メーカーや機種ごとに独自のコマンド体系が使われていました。
SCPIでないコマンド体系を持つ計測器であっても、VISAに準拠していれば以降で紹介するのと同じようにPythonから扱えるものも多いです。

## Pythonから制御する

PythonにはVISAに対応した計測器を制御する、pyvisaというライブラリがあります。

**pyvisa** https://pyvisa.readthedocs.io/en/latest/

writeやqueryというメソッドを使ってSCPIのコマンドを文字列として送受信します。
pyvisaから計測器を制御するときには、
初期化処理とwrite, query, query_binary_valuesをよく使います(これしか使わないかも)。

```
# 計測器に*RSTコマンドを送る(計測器のリセット)
inst.write('*RST')
# 計測器の持つ識別情報を読み取る
idn = inst.query('*IDN?')
```

pyvisaを使うにはVISAのバックエンドとして働くVISA規格が実装されたライブラリも必要になります。
特にこだわりがなくPythonからしか使わないのであれば、PyVISA-pyというVISAのPython実装を使うと楽です。

**PyVISA-py** https://pypi.org/project/PyVISA-py/

ほかにもNIが無料で提供しているNI-VISAもよく使われている気がします。
なんでもいいのでVISAライブラリが一つ入っていればpyvisaからVISA準拠の計測器を制御できるようになります。

# 実際にオシロをPythonから制御する

ここではRIGOL MSO5000シリーズのオシロに限って、LANで接続する場合とUSBで接続する場合を紹介します。
LANで繋ぐとPC側にドライバなどが必要なく楽なのでおススメです。

## 必要なソフトをinstallする

PythonからLAN経由でRIGOLのオシロを制御する場合は、Pythonに加えて以下の2つが必要です。

* pyvisa
* pyvisa py

これらはPyPIに登録されているので、以下ようにpipを使ってinstallできます。

```
pip install pyvisa pyvisa-py
```

これらに加えて、USB経由で制御する場合はPC側にドライバが必要です。
RIGOL公式のUltra SIgmaというソフトをinsltallするとドライバとユーティリティ類が揃いました。
Ultra Sigmaは以下のページの「SOFTWARE & FIRMWARE」 - 「Ultra Sigma Installer」という項目からdownloadしてinstallしました。

**RIGOL MSO5000**: https://jp.rigol.com/products/oscillosopes/mso5000.html

これをinstallするとNI-VISAがinstallされます。
NI-VISAがinstallされている場合はpyvisa-pyをinstallする必要はありません。


## VISA addressを調べる

VISAに準拠した計測器にはVISA addressという識別子が割り当てられます。
同じ計測器でもインターフェース(GPIB, USB, LANなど)ごとに違うaddressが割り当てられます。

### LANを使う場合

オシロをLANで接続するために、PC側にドライバなどのソフトの準備は必要ありません。
オシロ側でLANの設定をするだけで十分です。

VISA addressはオシロのLANの設定画面から確認することができます。
私は固定IPで192.168.1.21を割り当てたので、VISA addressは```TCPIP::192.168.1.21::INSTR```になっていました。

![](/images/rigol5k_lansetting.png){:data-action="zoom"}


### USBを使う場合

オシロをUSBでPCに接続するするには、PC側に前述のドライバが必要です。
Ultra Sigmaをinstall後にオシロをUSBでPCに接続すると、Ultra sigmaからVISA addressを確認することができます。
私の環境では```USB0::0x1AB1::0x0515::{serial_number}::INSTR```となっていました。

![](/images/rigol5k_visaaddress.png){:data-action="zoom"}

USBを使う場合もLANから使う場合も、VISA addressにはaliasという別名をつけることができます。
Ultara Sigmaからaliasを設定したい addressを選んで右クリックし、「Operation」-「Alias Manager」を選択するとaliasを設定する画面が開きます。
aliasを設定しておけば、毎回長いVISA addressを設定しなくても、わかりやすい自分の設定した文字列で計測器にアクセスできるようになります。
上の画像ではaliasとしてscopeを設定しています。


## SCPI コマンドを調べる

SCPIに対応している計測器には、SCPIのコマンドのリファレンスマニュアルが準備されているはずです。
RIGOL MSO5000では以下のページの「Manual」-「MSO5000 Programming Manual」がそれに該当します。

**RIGOL MSO5000**: https://jp.rigol.com/products/oscillosopes/mso5000.html

ここにSCPIコマンドの定義が書いてあり、このコマンドを使って計測器を制御します。
メーカーや計測器によって同じコマンドでも動作が違うことがよくあるので注意が必要です。
SCPIの構文もたいていマニュアルの最初の方に書いてあるので、
初めての場合でもそこを読めば雰囲気がわかると思います。

SCPIコマンドの中には*(アスタリスク)から始まるIEEE488.2の共通コマンドというものがあります。
これはSCPIに対応している計測器で共通して使えるコマンドです。
計測器の識別情報を取得する\*IDN?、計測器をリセットする\*RST、命令の実行を待機する\*OPC?辺りはよく使います。


## 例1 計測器と正常に通信ができるかを確認する

まずは計測器と通信がうまくできることを確認するために、
SCPIの*IDNコマンドを使って計測器の識別情報を読みだしてみます。
前述のPythonの環境ができた状態で以下のスクリプトを実行すると、\*IDN?で取得できる識別情報が表示されます。

```
import visa

inst = visa.ResourceManager().open_resource('TCPIP::192.168.1.21::INSTR')
print(inst.query('*IDN?').strip())
```

```open_resource```の引数にはVISA addressを指定します。ここにはVISA addressのaliasを設定することもできます。

識別情報はカンマ区切りで、以下の意味を持ちます。

```
<manufacturer>,<#model>,<#serial>,<FW revision>
```


## 例2 スクリーンキャプチャを保存する

オシロスコープの画面そのものを画像として保存してみます。
オシロにUSBメモリを挿して手動で保存するよりも楽だと思います。

以下のスクリプトをload_screen.pyというファイルに保存したとして、次のコマンドを実行します。


```
$ python python load_screen.py -a TCPIP::192.168.1.21::INSTR -o test.png
```

するとVISA addressがTCPIP::192.168.1.21::INSTRであるオシロから画面のデータ読みだしてtest.pngの画像ファイルに保存します。
このスクリプトではPILを使っているので、PILもinstallが必要です。

<script src="https://gist.github.com/idt12312/98f52c0b524b9cc5fbda9dfd84a3f421.js"></script>

RIGOL MSO5000では:DISP:DATAコマンドで画面のデータをbitmap形式で取得できます。
SCPIでは基本的に文字列でデータをやり取りしますが、たまにバイナリデータを扱うこともあります。
今回の例では、:DSIP:DATA?を送るとbitmapのバイナリデータが送られてきます。このバイナリデータはファイルにそのまま保存するとbitmapファイルになるようなデータです。

pyvisaでは```query_binary_values```を使うと、バイナリデータの解釈方法や保存方法を指定してデータを受け取ることができます。
上の例ではバイナリデータをbyteごとにPythonのbytesに詰めています。
datatypeにはPythonのstructと同じようなformat文字を設定できますので、「受け取ったデータを4バイトづつlittle endianとして整数に解釈していく」処理も簡単にできます。
データを入れる先はnumpyのndarrayなども指定できるので、受け取った大量のデータをそのままnumpyでのデータ処理に流していくこともできます。

今回の主題からは外れますが、bmpだとサイズが大きいのでPILを使ってpngに変換して保存しています。
出力ファイル名に.jpegなどを指定すれば.jpegで保存することもできます。対応しているformatはPILのsaveが対応している形式です。

このスクリプトを使って取得した画面のキャプチャは以下のようになります。

![](/images/rigol5k_screen.png){:data-action="zoom"}

これはI2Cの通信のデバッグをしているところです。
MSO5000にはアナログCHの信号もいくらかのプロトコルで解釈してくれる機能があります。

## 例3 波形データをcsvファイルに保存する

次はオシロスコープで取得した波形データをcsvファイルで保存してみます。

以下のスクリプトをload_screen.pyというファイルに保存したとして、次のコマンドを実行します。

```
$ python save_as_csv.py -a TCPIP::192.168.1.21::INSTR -c 1,2 -o test.csv -p 10000
```

するととVISA addressがTCPIP::192.168.1.21::INSTRであるオシロのCH1,2から10000点データを読みだして、test.csvに保存します。

<script src="https://gist.github.com/idt12312/a9d9a600a100b7d0ad121114d1d4cf5d.js"></script>

オシロがRUN状態だとどのデータが読みだされるのかはっきりとしないので、
データを読みだす前にオシロをSTOP状態にしています。

オシロからデータを読みだして解釈する部分は```load_waveform```関数に書いてあります。

波形データ自体はWAV:DATAコマンドで読みだせるのですが、読みだしたデータを物理量に直すためには:WAV:PREコマンドで取得したパラメータも必要です。
データの解釈方法はマニュアルに書いてあります。

load_waveform関数の冒頭では以下の設定をしています。

* :WAV:SOUR 読みだすデータ(CHなど)を一つ選択する
* :WAV:MODE RAW,NORM,MAXが選択する
* :WAV:POIN 読みだすデータ点数を指定する
* :WAV:FORM 文字列('2.34E-3'のように)で送るか、1点を2byteで送るか1byteで送るかを選択する

オシロの測定値はメモリに保存されていて、その一部が画面に表示されています。:WAV:MODEでは画面に表示されているものをから読みだすのか、メモリにあるものを読みだすのかを選択できます。MODEとデータ点数(:WAV:POIN)によってデータが間引かれたりもします。この辺りはオシロによってかなり動作が違うので要注意です。

:WAV:FORMを文字列に指定するとデバッグはしやすくなるのですが、数万点のデータを転送するにに結構時間がかかります。時間短縮のためにbyteを選択しておくのが無難です。多くのオシロのADCは8bitなので、1点あたり1byteで事足ります。ADCが8bitよりも大きいオシロの場合や、8bit ADCでもAcuire modeをaverageやhigh resokutionにしているときは1点の分解能がbitを超える場合があります。そういう時は:WAV:FORMをwordにして1点を2byteで送ると分解能を保ちつつ高速にデータの転送ができます。RIGO MSO5000はADCが8bitで、average modeで動かしても分解能が8bit以上にはならないのでwordを設定する利点はありません。


## 例4 Jupyter notebookから使う

Pythonからオシロを扱えるということは、もちろんJupyter notebookからもオシロを制御することができます。
オシロからデータを読みだし、その結果を処理する部分もJupyter notebookで完結させることができます。

![](/images/rigol5k_notebook.png){:data-action="zoom"}


# おわりに
この記事ではPythonからRIGOL MSO5000を制御する方法を紹介しました。
計測器の自動制御は趣味用途だとあまり使わないかもしれませんが、たくさん同じような測定をしたいときには重宝します。
