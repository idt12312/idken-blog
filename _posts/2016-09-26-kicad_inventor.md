---
layout: post
title: KiCadでInventorの面データを読み込む
category: KiCad
tag:
    - KiCad
    - Inventor
comments: true
thumb: https://raw.githubusercontent.com/KiCad/kicad-source-mirror/master/bitmaps_png/icons/icon_kicad.ico
---
Inventorで設計した面のデータをKiCadに読み込ませる方法について


KiCadはdxfデータを読み込むことができます。
読み込んだデータを基板外形データとして扱うことができるので、
基板の外形を別の機械CADで設計し、そのデータをKiCadに読み込ませるという使い方ができます。
KiCadは基板の設計用ということで、まだ機械CADのような使い勝手で基板の形状や寸法をいじることはできません。
四角形の基板なら問題ないのですが、複雑な形状をしていたり、
取り付け用の穴の位置が中途半端なところにある場合はKiCadだけで外形や穴を作るのはとても手間です。
なのでそういった部分は機械CADで作り、回路部分はKiCadで作るという分担作業をしようというわけです。

ちなみにマイクロマウスの基板もそのようにして設計をしました。
機械CADはInventorしか使えないので、モータやタイヤとの位置関係をみつつInventorで基板の外形を設計しました。
こんな感じです。  

![](/images/mouse_inventor.jpg)

しかし、その基板の外形データをKiCadに取り込む際に問題が起こりました。


# Inventorで出力したdxfをKiCadで読み込む
次のようにしてInventorで設計したデータをKiCadに取り込もうとしました。

1. Inventorでdxfファイルを出力
2. KiCadでdxfファイルを読み込む

Inventorからは次のように面を指定してdxfデータを出力することができます。

![](/images/indentor_dxf.jpg)

こうして出力したdxfファイルをKiCadに直接取り込むとこんな感じになります。

![](/images/dxf_kicad1.jpg)

フィレットをつけていた部分が全て斜めの直線に置き換わり、カクカクになってしまいました。

Inventorの出すdxfは特殊仕様になっているらしく、うまくできなかったのだと思います。
(KiCadに限らずdxfファイルを使うときは大抵問題が起きるような...)

# 解決策
いろいろ試した結果、次の方法でうまくいきました。

1. OnShapeでInventorの部品(.iptファイル)を読み込む
2. OnShapeでdxfファイルを出力
3. KiCadでdxfファイルを読み込む

KiCadはInventorから出力されるdxfをうまく読み込むことはできませんでしたが、
OnShapeの出力するdxfファイルならうまく読みことができました。
なのでOnShapeを一旦経由することで乗り切っています。

ちなみにOnShapeとはブラウザで動く3DCADです。
[こちらで紹介されています。](http://titech-ssr.blog.jp/archives/1034902634.html)

## OnShapeでInventorの部品を読み込む
OnShapeのUploadボタン的なものを押すとローカルのファイルを選ぶ画面がでるので、
そこで基板の外形であるInventorの部品データ(.ipt)を選択し、uploadします。

![](/images/import_ipt.jpg)

## OnShapeでdxfファイルを出力
Inventorのデータをuploadすると、Document内に新たな部品ができます。
その部品を開き、出力したい面を選択して右クリックをすると↓のようなメニューができると思います。
「Export as DXF/DWG..」を選択するとファイル形式を選ぶ画面になるので、
DXFを選ぶとローカルにDXFファイルがダウンロードされます。

![](/images/dxf_onshape.jpg)

## KiCadでdxfファイルを読み込む
KiCadのメニューの「File」->「Import」の中にdxfファイルを読み込む選択しがあると思うので、
それを押します。
開いた画面で先ほどダウンロードされたdxfファイルを選択すると基板データの中に取り込むことができます。  

![](/images/dxf_kicad2.jpg)

先ほどとは違って曲線がちゃんと曲線になっているのがわかると思います。
