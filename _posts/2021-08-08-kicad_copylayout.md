---
layout: post
title: KiCadで部品配置・配線の繰り返しコピーを簡単に作成する
category: KiCad
tag:
    - KiCad
comments: true
thumb: /images/thumb_kicad.png
---
KiCadで部品配置・配線などの繰り返しコピーを簡単に作成する方法を紹介します。


## はじめに

KiCadのpcbnewにおいて、部品配置・配線などの繰り返しコピーを簡単に作成する方法を紹介します。
具体的には以下の画像のように、階層シートを使って作った複数個の同じ回路をもとに、
基板データ上でも部品配置・配線の繰り返しコピーを作成します。
![](/images/kicad_copylayout_abstruct.png){:data-action="zoom"}

多くの繰り返しパターンを作る必要がある回路を作ったときにどうにか効率化できないかと試行錯誤して、ここに紹介する方法に至りました。
ちなみに、このような回路のコピーを行う方法を検索すると以下のようなものがあります。

[Github: tlantela/KiCAD_layout_cloner](https://github.com/tlantela/KiCAD_layout_cloner)

この方法を使うと、今回紹介するパターンはPythonのスクリプトを実行するだけで非常に簡単に実現できます。
ただ、このスクリプトでは格子状にしか繰り返しコピーを作ることができません。
私は格子状ではない繰り返しパターンを作りたかったので、別の方法を探ることにしました。
この記事で紹介する方法は多少自動化による操作の少なさを犠牲にしつつ、繰り返しコピーを任意の場所の配置できることがポイントです。

記事の前半では繰り返しコピーを作成する方法について簡単な例をもとに紹介します。
後半では、作業の中で最も面倒な部品番号を書き換える作業をKiCadの組み込みPythonを使って楽に行う方法を紹介します。

## 手順

この方法はあまり検証されていないので、ミスや想定外の挙動により設計データを破壊するかもしれません。
**実行する前に必ずKiCadのデータのバックアップを取っておきましょう**。

### 1. 回路図で繰り返しパターンをつくる

階層シートの機能を使って、以下のように同じ回路の繰り返しパターンを作ります。
回路は例を紹介するために作った適当な回路で、特に意味はありません。

![](/images/kicad_copylayout_schematic.png){:data-action="zoom"}

ちなみに階層シートを使うことは必須ではなく、面倒ですが階層シートを使わなくても同じようなことはできます。
今回の方法では以下の利点があるので階層シートを使っています。

* 手順2のように部品番号を規則的に割り当てられる
* 階層シート内の回路は完全に同じなので、pcbnewでのコピーが楽に済む


### 2. 繰り返しパターンにReferenceを規則的に割り当てる

Annotation機能を使うときに下の画像の赤枠のところを選択し、先頭の桁がシート番号になるようにReferenceを割り当てます。

![](/images/kicad_copylayout_annotation_100.png){:data-action="zoom"}

階層シートの番号の割り当て規則と番号の調整方法は以前記事にしていますので、
番号の割り当てに困ったら参考にしてください。

[**id研:KiCadの階層シートにおけるアノテーション**](/posts/2016-09-24-kicad_annotation)

### 3. 1ブロックだけ配置・配線する

回路図を完成させ、Footprintの割り当ても完了したらpcbnewからいつも通りnetlistを読み込みます。
その後繰り返しパターンのうちの1ブロックだけ部品配置と配線を完了させます。

![](/images/kicad_copylayout_create_1block.png){:data-action="zoom"}

手順5で行うコピーでは、シルクやソルダーマスクなどのオブジェクトもコピーできます。
コピー後にシルクを全部直すのも大変なので、この段階で部品のシルクも調整しておきます。


### 4. 他のブロックの部品をいったん削除する

繰り返しパターンのうち、コピー元のブロック以外のブロックの部品を削除します。
階層シートを使っていれば初期状態で同じシート内の部品は集まり、シートの異なる部品は離れてくれるので、削除すべき部品は見つかり安いです。

![](/images/kicad_copylayout_delete_others.png){:data-action="zoom"}

### 5. 配線済みブロックをコピーする

配線済みのブロックを必要な数だけコピーします。
Referenceはコピー元のブロックと同じままになっていたり、ネット名がちゃんと設定されていない状態になってしまいますが問題ありません。
配線がショートしている状態になってしまっても問題ありません。
これらは後で修正します。

![](/images/kicad_copylayout_copy_block.png){:data-action="zoom"}

とはいえ後で配線を修正しやすくするために、コピーする範囲や配線の引き出し方を工夫しておくとよいです。

### 6. Referenceを正しいものに戻す

Referenceが重複している状態になっているので、手動でReferenceを正常なものに戻していきます。
ここで変更するのはReferenceだけで、配線のNet名などは変更する必要がありません (むしろ変更してはいけないのかもしれない)。
**この作業は回路規模によっては非常に大変な作業です**。
このReferenceの変更作業はKiCad組み込みのPythonを使って多少楽にできたので、この記事の後半にその方法を書いています。

階層シートを使ってReferenceを「階層シート番号 x100やx1000」に設定している場合、Referenceの先頭の桁だけを変更していけばいいので多少楽になります。
階層シートを使うと楽になる理由はここにあります。

以下の画像はハイライトされている部品のReferenceを200番台から400番台に変更した後のものです。

![](/images/kicad_copylayout_rename.png){:data-action="zoom"}

今回は繰り返しパターンが全部で4つあり、それぞれ200 (コピー元)、300、400、500番台のReferenceが割り当てられています。
4つすべてのReferenceを修正した後の状態が以下のものになります。

![](/images/kicad_copylayout_rename_complete.png){:data-action="zoom"}


### 7. Netlistを読み込みnetを再設定する

Referenceが正常な状態になったので、次はNetを正常な状態に戻します。
Netlistの読み込み画面で、以下の画像のように設定をして部品のReferenceを基づいてNetlistを再割り当てします。
すでに必要な部品は基板上に配置され、Referenceも回路図と同じものが割り当てられているので、コピーした配線には意図通りのNet名が割り当てられるはずです。

![](/images/kicad_copylayout_update_netlist.png){:data-action="zoom"}


### 8. 完成

Netlistを再読み込みした後、繰り返しパターンの端や基板の共通部分の配線を行い完成です。
配線は単純にコピーをしているので、端のパターンではどこかと配線がかぶってしまったりします。
DRCを実行して電気的にNGな部分を探しながら配線を微調整していきます。

![](/images/kicad_copylayout_complete.png){:data-action="zoom"}


## Pythonを使ってRename作業を楽に行う

手順6でのReferenceをrenameする作業が非常に面倒なので、なんとか簡単にする方法を考えました。
ここではKiCad組み込みのPythonを使ってrenameを多少自動化する方法を紹介します。

階層シートを使ってReferenceの番号の先頭の桁が階層シートの番号になっていて、
それより下の桁が繰り返しパターンの間で同じになっている場合に適用できる方法です。

### 0. Pythonスクリプトの準備

以下のpythonスクリプトを基板データと同じディレクトリにコピーします。

https://gist.github.com/idt12312/ab038dd71863a20302c0b5a5366fbf7b


### 1. 部品を選択する

手順5までの作業が完了した状態で、Renameをしたい部品を選択します。
多くの部品を手動で漏れなく手動で選択するのは大変なので、Select Filter機能を使います。

まず、選択したい部品のあるエリアを配線やシルクも含めて範囲選択します。
以下の画像のように、部品だけではなくシルクや配線も選択さ入れてハイライトされている状態です。
その後右クリックして"Select" -> "Filter Selection"と選択してFilter Selection画面の開きます。
今は部品だけを選択したいので、"include footprint"を選択します。

![](/images/kicad_copylayout_select_component.png){:data-action="zoom"}

そうすると以下のように部品だけを選択している状態になります。

![](/images/kicad_copylayout_selected.png){:data-action="zoom"}


### 2. rename_leading_number_selectedを実行する

KiCadのPython consoleから以下のコマンドを実行して、選択されている部品の先頭の数字を指定したものに変更します。

```
from rename_leading_number_selected import rename_leading_number_selected
rename_leading_number_selected(4)
```

![](/images/kicad_copylayout_python_console.png){:data-action="zoom"}

ここでは先頭の数字を4に変えるので、rename_leading_number_selectedの関数の引数に4を渡します。
この数値は2桁(12とか)でも問題ありません。

### 3. Referenceが変わったことを確認する

ぱっと見では番号が変わっていないかもしれませんが、拡大縮小したり、部品のプロパティを開いたりすると画面が更新されてReferenceが変化するはずです。

![](/images/kicad_copylayout_rename.png){:data-action="zoom"}

### Pythonのスクリプトについて

Pythonのスクリプトでは、rename対象を"選択された部品"に指定することで部品選択はGUI、繰り返し処理はPythonと分業をしました。
Pythonに何か処理をやらせるときに、処理対象オブジェクトの条件が「基板上の部品全て」や「抵抗全て」などシンプルな場合は処理対象オブジェクトの選択もPythonにやらせた方が楽です。
処理対象の条件が複雑 or 作るのが面倒な時は今回のように「GUI上で選択されているもの」とするといろんな状況で使いやすいと思いました。

PythonでGUI上で選択されている部品の取得は以下のような処理で実現しました。
IsSelected()でGUI上で選択されているかどうかが取得できたので、それを利用しています。

```
def _get_selected_modules():
    modules = pcbnew.GetBoard().GetModules()
    return filter(lambda m: m.IsSelected(), modules)
```
今回はこの関数で取得した部品のReferenceを変更しましたが、シルクを消す、シルクサイズを変更するといった別の一括処理のためにも使えるなと思いました。

## おわりに

pcbnew上で単純に部品と配線をコピーすることで繰り返しパターンを作りました。
その後部品のReferenceは手動 or 最後に紹介したpythonを使った方法で修正し、再度Netlistを読み込むことでNetも回路図と矛盾をなくすことができました。

格子状のパターン作成であれば冒頭に紹介した以下のものが便利かもしれませんが、より自由な配置を行うときにはこの記事で紹介した方法を使ってみてください。

[Github: tlantela/KiCAD_layout_cloner](https://github.com/tlantela/KiCAD_layout_cloner)
