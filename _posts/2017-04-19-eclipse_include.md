---
layout: post
title: Eclipseのinclude pathを自動で設定する
category: Eclipse
tag:
    - Eclipse
    - マイコン
comments: true
thumb: /images/eclipse.ico
---
EclipseでC/C++を開発する際のinclude pathの設定をある程度自動化してみました。



# はじめに
私はARMなマイコンを開発する際にEclipse+CDTでC/C++を使って開発をしています。
プロジェクトを作成した時に毎回使用するライブラリに対してincude pathを設定する必要があり、
ライブラリのディレクトリ構造によってはものすごい数のpathを設定しないといけない場合があります。

例えばSTM32F4のStandard Peripheral Libraryはこんな感じの構造になっているので、
STM32F4xx_StdPeriph_Driver/incに対してのみpathを設定してやればOKです。

* STM32F4xx_StdPeriph_Driver/
    * src/
        * *.c
    * inc/
        * *.h

しかし、[B-ARTの開発](http://idken.net/posts/2017-04-04-b-art/)の際に使った
[NordicのnRF5 SDK](https://www.nordicsemi.com/eng/Products/Bluetooth-low-energy/nRF5-SDK)は
次のような構造をしているため、大量のディレクトリに対してpathを設定しないといけません。
(必要なもののみを抽出したとしてもかなりの量)

* nRF5_SDK_13.0.0_04a0bfd/
    * components/
        * ble/
            * ble_advertising/
                * ble_advertising.h
                * ble_advertising.c
            * ble_services/
                * ble_bas/
                    * ble_bas.h
                    * ble_bas.c
                * ble_hrs/
                    * ble_hrs.h
                    * blr_hrs.c
                * ...
            * ...
        * drivers_nrf/
            * uart/
                * nrf_drv_uart.c
                * nrf_drv_uart.h
            * timer/
                * nrf_drv_timer.c
                * nrf_drv_timer.h
            * ...
        * ...
    * external/
    * ...


そこで、eclipseのプロジェクト下にあるディレクトリ全て(選択もできる)をinclude pathに追加する
作業を自動化する方法を考えました。

# 自動化する方法
## 手順1 
以下のスクリプトをeclipseのプロジェクトのroot(.projectとか.settingがあるとこ)に置きます。
ここではファイル名をgen_inc_pathとします。

```sh
#/bin/sh

output_filename='inculde_setting.xml'

if [ $# -eq 0 ]; then
	found_dir=`find * -name '.*' -prune -o -type d -print`
else
	for search_dir in $@
	do
		found_dir="$found_dir`find $search_dir -name '.*' -prune -o -type d -print` "
	done
fi

for inc_path in $found_dir
do
	inc_path_setting="${inc_path_setting}<includepath>${inc_path}</includepath>\n"
done

echo -e \
"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<cdtprojectproperties>
<section name=\"org.eclipse.cdt.internal.ui.wizards.settingswizards.IncludePaths\">
<language name=\"C Source File\">
${inc_path_setting}
</language>
<language name=\"C++ Source File\">
${inc_path_setting}
</language>
</section>
</cdtprojectproperties>" > ${output_filename}
```

## 手順2 
プロジェクトのディレクトリにある全てのディレクトリをinclude pathに追加する場合は

```sh
./gen_inc_path 
```

特定のディレクトリ(dir1, dir2)を追加したいときは

```sh
./gen_inc_path dir1 dir2
```

を実行します。
そうするとinculde_setting.xmlが出力されます。

**ちなみに隠しディレクトリは無視するようになっています。**

## 手順3
EclipseのProjectの[Properties]->[C/C++ General]->[Path and Symbols]を開き、
Import Settings...を押します。

開いた画面で[Settings file]には先ほど生成したinclude_setting.xmlを選択し、
include pathを設定したいプロジェクトと設定したいビルド(Debug, Releaseとか)を選択します。

![](/images/eclipse_inc_import.png){:data-action="zoom"}

あとはFinishを押すとinclude pathが読み込まれます。


## 注意
すでに設定されているpathをもう一度include_setting.xmlから設定しても、
重複がなくなるように設定されるので問題はありません。


生成するxmlファイルではとりあえず'<language name=\"C Source File\">'と'<language name=\"C++ Source File\">'
のデータを作っています。片方が必要なければスクリプト中の該当箇所を消してください。
ちなみにプロジェクトの設定にない言語が設定ファイルにあったとしても、プロジェクトに設定されている言語の設定のみが読み込まれるみたいです。


# おわりに
もっとちゃんとした、eclipse内で完結できる方法をご存知の方がいましたらぜひ教えてください。
