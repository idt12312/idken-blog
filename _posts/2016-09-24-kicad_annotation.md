---
layout: post
title: KiCadのアノテーション
category: KiCad
tag:
    - KiCad
comments: true
thumb: /images/thumb_kicad.png
---
KiCadで階層シートを使っている状況でのアノテーション機能の挙動についてです。


# KiCadのアノテーションで少し困ること

KiCadには部品番号を自動で振るアノテーション機能があります。
設定画面でX方向Y方向どちらを優先するかを設定してやれば部品の配置に応じて番号を振ることができます。

![](/images/kicad_annotation_config.png){:data-action="zoom"}


しかし、階層シートを使うと思った通りに部品に番号を触れない時があります。
例えば次のような回路図(ファイル名はannotation.sch)があったとします。

![](/images/kicad_annotation1.png){:data-action="zoom"}

階層シートのルートになっていて、sub_sheet_A,B,Cを子に持っています。(わかりやすくするために子シートの中身も表示しています。)

この状態でアノテーションを実行すると、次のように番号が振られます。

![](/images/kicad_annotation2.png){:data-action="zoom"}

大枠としてC->B->Aの順に番号が振られていることがわかると思います。
アノテーションの設定でX,Yの優先をどう設定しても子シート内の番号の振り方が変わるのみで、
C->B->Aの順番は変わりません。

今回はあまり問題ではないかもしれませんが、やはりA->B->Cの順番に並べたい時、
またはBが複数あってA->B1->B2->B3->Cのように番号を振ってほしい時というのはあると思います。
しかしKiCadのドキュメント中からこういう場合にはどうすれば良いのかを知ることができなかったので、
いろいろ試して解決方法を探りました。


# 階層シートを含むアノテーションの挙動

先ほどの画像として出てきた回路図のファイル、annotation.schの中身を見るとこんな感じになっています。

```
EESchema Schematic File Version 2
LIBS:power
(省略)
LIBS:annotation-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
(省略)
$EndDescr
$Sheet
S 6600 3175 1375 1250
U 5855E7F4
F0 "sub_sheet_C" 60
F1 "sub_sheet_C.sch" 60
$EndSheet
$Sheet
S 4900 3175 1375 1250
U 5855E80B
F0 "sub_sheet_B" 60
F1 "sub_sheet_B.sch" 60
$EndSheet
$Sheet
S 3200 3175 1375 1250
U 5855E815
F0 "sub_sheet_A" 60
F1 "sub_sheet_A.sch" 60
$EndSheet
$EndSCHEMATC
```

注目すべきなのは後半の$Sheet~$EndSheetの塊が並んでいる部分です。
この$Sheet~$EndSheetの部分にのみsub_sheet_*.schという文字列が出てきているので、
この部分で子シートは参照されているのです。

$Sheet~$EndSheetの塊の順番に注目するとC->B->Aの順になっています。
アノテーションはこの順番にされるようです。(色々試した結果に基づく想像ですが)


# 自在に番号を振る

階層シートのアノテーションの挙動がわかったので、
$Sheet~$EndSheetの塊を並べ替えてみます。

A->B->Cの順に番号を振ってほしいので、annotation.schの中身を次のように編集します。

```
EESchema Schematic File Version 2
LIBS:power
…
LIBS:annotation-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
…
$EndDescr
$Sheet
S 3200 3175 1375 1250
U 5855E815
F0 "sub_sheet_A" 60
F1 "sub_sheet_A.sch" 60
$EndSheet
$Sheet
S 4900 3175 1375 1250
U 5855E80B
F0 "sub_sheet_B" 60
F1 "sub_sheet_B.sch" 60
$EndSheet
$Sheet
S 6600 3175 1375 1250
U 5855E7F4
F0 "sub_sheet_C" 60
F1 "sub_sheet_C.sch" 60
$EndSheet
$EndSCHEMATC
```

A->B->Cの順に参照しています。

ファイルを編集後にアノテーションを実行するとこうなりました。

![](/images/kicad_annotation3.png){:data-action="zoom"}

実現したかった順に番号が振られています。

