---
layout: post
title: J-LinkでコマンドラインからマイコンのFlashに書き込む
category: マイコン
tag:
    - マイコン
    - ARM
    - J-Link
comments: true
thumb: /images/thumb_jlink.png
---
J-Linkを使ってコマンド一発でマイコン(STM32)のFlashにプログラムを書き込む方法の紹介をします。

## はじめに
J-LinkをJLinkExeから操作をすることでコマンドライン上からFlash書き込みをします。
デバッガは起動せずにFlash書き込みだけで十分であり、コマンドラインからコマンドを呼び出すだけでFlashに書き込みたいという場合に有用です。

J-Linkの他の機能に関しては以下の記事に色々書いています。

[**id研：超便利 最強デバッガ J-Link**](http://idken.net/posts/2017-08-31-jlink/)

JLinkExeにはコマンドライン引数だけで書き込むを行う機能はないので、
以下の手順でFlashに書き込みます。

1. JLinkExeの実行するスクリプトファイルを作成する
1. JLinkExeのコマンドライン引数で1のスクリプトを呼び出す

JLinkExeで実行するスクリプトファイルはJLinkExeのinteractive shellで実行できるコマンドを並べたものです。

## 手順

J-Linkを使ってSTM32にSWD経由でFlash書き込む例を紹介します。
STM32以外もJ-Linkが対応していれば同じようなことができるはずです。
Linux上でしか試していませんが、WindowsでもJ-Linkのコマンドライン用プログラムを使えば同じことができるはずです。

### 手順1. JLinkExeのためのスクリプトファイルを作成する

以下の内容の書かれたdownload_flash.jlinkという名前(ファイル名は任意)で作成します。

```
r
loadfile program.bin
q
```

マイコンリセット→Flash書き込み→終了という3つの操作を並べています。
このコマンドはJLinkExe上で実行できるコマンドなので、もちろん他のコマンドを並べることも可能です。
J-Linkから5Vの電源供給を行うこともできるので、電源供給開始→マイコンリセット→Flash書き込みという動作もできます。

program.binはマイコンに書き込みたいバイナリファイル名です。
ファイル名は絶対パスか、次の手順でJLinkExeを実行するディレクトリからの相対パスで指定します。
.binファイル以外にも.motや.hexでも書き込めます。
いつもデバッグで使っている.elfファイルは対応していなかったので、objcopyで.elfから.binファイルに変換しました。


### 手順2. JLinkExeから手順1のスクリプトを実行する

手順1で作成したdownload_flash.jlinkと同じディレクトリで以下のコマンドを実行します。

```
JLinkExe -device STM32F413CG -if SWD -speed 4000 -autoconnect 1 -CommanderScript download_flash.jlink
```

device, if, speedで指定しているパラメータは適宜書き換えてください。

うまく書き込めると次のような出力が得られます。

```
# JLinkExe -device STM32F413CG -if SWD -speed 4000 -autoconnect 1 -CommanderScript download_flash.jlink
SEGGER J-Link Commander V6.30c (Compiled Feb  9 2018 17:22:34)
DLL version V6.30c, compiled Feb  9 2018 17:22:28

Script file read successfully.
Processing script file...

J-Link connection not established yet but required for command.
Connecting to J-Link via USB...O.K.
Firmware: J-Link V9 compiled May 17 2019 09:50:41
Hardware version: V9.40
S/N: xxxxxxxxxxx
License(s): FlashBP, GDB
OEM: SEGGER-EDU
VTref = 2.805V
Target connection not established yet but required for command.
Device "STM32F413CG" selected.

Connecting to target via SWD
Found SW-DP with ID 0x2BA01477
Found SW-DP with ID 0x2BA01477
Scanning AP map to find all available APs
AP[1]: Stopped AP scan as end of AP map has been reached
AP[0]: AHB-AP (IDR: 0x24770011)
Iterating through AP map to find AHB-AP to use
AP[0]: Core found
AP[0]: AHB-AP ROM base: 0xE00FF000
CPUID register: 0x410FC241. Implementer code: 0x41 (ARM)
Found Cortex-M4 r0p1, Little endian.
FPUnit: 6 code (BP) slots and 2 literal slots
CoreSight components:
ROMTbl[0] @ E00FF000
ROMTbl[0][0]: E000E000, CID: B105E00D, PID: 000BB00C SCS-M7
ROMTbl[0][1]: E0001000, CID: B105E00D, PID: 003BB002 DWT
ROMTbl[0][2]: E0002000, CID: B105E00D, PID: 002BB003 FPB
ROMTbl[0][3]: E0000000, CID: B105E00D, PID: 003BB001 ITM
ROMTbl[0][4]: E0040000, CID: B105900D, PID: 000BB9A1 TPIU
ROMTbl[0][5]: E0041000, CID: B105900D, PID: 000BB925 ETM
Cortex-M4 identified.
Reset delay: 0 ms
Reset type NORMAL: Resets core & peripherals via SYSRESETREQ & VECTRESET bit.
Reset: Halt core after reset via DEMCR.VC_CORERESET.
Reset: Reset device via AIRCR.SYSRESETREQ.

Downloading file [program.bin]...
Comparing flash   [100%] Done.
Erasing flash     [100%] Done.
Programming flash [100%] Done.
Verifying flash   [100%] Done.
J-Link: Flash download: Bank 0 @ 0x08000000: 1 range affected (32768 bytes)
J-Link: Flash download: Total time needed: 0.885s (Prepare: 0.018s, Compare: 0.204s, Erase: 0.533s, Program: 0.123s, Verify: 0.000s, Restore: 0.004s)
O.K.

Script processing completed.
```

JLinkExeがSTM32にconnectした後に書き込んでいる様子が分かります。
