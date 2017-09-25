---
layout: post
title: スラロームができた
category: マイクロマウス
tag:
    - ロボット
    - MIZUHO
comments: true
thumb: /images/thumb_mouse_slalom.jpg
---
スラローム走行ができるようになりました。(おそい....)


ペリフェラル部分や制御の基礎部分を実装し終わり、スラローム走行ができるようになりました。  

<div class="movie-wrap">
<iframe width="560" height="315" src="https://www.youtube.com/embed/v4nUVmx2mds" frameborder="0" allowfullscreen></iframe>
</div>

非常におそいですね。(マシンの速度も、進捗も)
まだパラメータを詰めるということをしていないので、
単純にこれ以上速度をあげるとどんどん外回りになっていってしまいます。

ちなみに制御はこんな感じの2重ループで実装しています。

![](/images/control.png){:data-action="zoom"}

目標位置を与えるとその位置に動くような制御をかけておき、
目標位置を好きな軌道上で動かしてやることで軌道上を走らせるという仕組みです。
詳細はまたいつか書きます。