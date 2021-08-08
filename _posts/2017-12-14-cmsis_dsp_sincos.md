---
layout: post
title: CMSIS DSPのarm_sin_f32とarm_cos_f32
category: マイコン
tag:
    - マイコン
    - STM32
comments: true
thumb: /images/thumb_stm32.jpg
---
CMSIS DSPのarm_sin_f32とarm_cos_f32でハマった話と使用上の注意。


# 結論
**CMSIS DSPのarm_sin_f32とarm_cos_f32 の引数は[0 2π)の範囲の値であることが必要**

この事実は最近までドキュメントに明記されていませんでした。

以前arm_cos_f32にこの範囲外の値を入れて、謎バグを発生させてハマってしまった経験をしました。
その後GithubでIssueを立てたらARMの人に対応をしていただくことができ、無事に解決することができました。


# 経緯
## なんかバグった
10月終わりごろ、arm_cos_f32の引数に-π/2あたりの数字を入れるとなぜか2πが返ってくるという現象が発生しました。

具体的には、εを32bit float で表現できる最小の数だとしたら、
-π/2+εと2π/2+2ε(floatで16進数表記すると0xbfc90fdc, 0x0xbfc90fdd)を入れるとだいたい2πくらいの値が返ってきました。

C言語で書くとこんな感じです。
cos_resultはほぼ0になってほしいのですが、2πあたりの値になってしまいます。

```c
uint32_t x_bin = 0xbfc90fdc;
float *x = (float*)&x_bin;  // *x is -pi/2 in float
float cos_result = arm_cos_f32(*x);
```

ちなみに-π/2-εや2π/2+3εを入れた場合には正常な0に近い値が返ってきます。


## Issueで質問してみる
運のいいことに、ARM の CMSIS-DSP ライブラリはGitHubでオープンソースな開発が行われています。
そこでIssueで問題を報告してみました。

[**Guthub: CMSIS_5 Issue #267**](https://github.com/ARM-software/CMSIS_5/issues/267)

その結果、arm_cos_f32の引数は0～2πの範囲の値である必要があるという事実が分かりました(arm_sin_f32も)。

ドキュメントにはarm_cos_q15とarm_cos_q31に関しては、以前から[0 2π)に相当する[0 +0.9999]の値しか入れないでねと書いてありました。
arm_cos_f32のところには「引数はラジアンで」としか書かれていなかったので負の数でもなんでも問題ないと思っていましたが、そうでもなかったということです。


## ドキュメントが修正される
このあたりのcommitでソースコードのコメントに追記がされました。

https://github.com/ARM-software/CMSIS_5/commit/8c019d4906ca477a33c6268186ef97bcfffd7bbf#diff-b4218bc40c37d76a26966a73978399e6

Doxygen用のコメントにもなっているので、文章としてのドキュメントにもちゃんと反映されていると思います。


些細なこととは言えども、個人的には初めてOSCに貢献?できてうれしかったです。


# 結論
**CMSIS DSPのarm_sin_f32とarm_cos_f32 の引数は[0 2π)の範囲の値であることが必要**
