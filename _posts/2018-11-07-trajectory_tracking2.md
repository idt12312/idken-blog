---
layout: post
title: 独立二輪車型ロボットで目標軌道に追従する制御をする②
category: マイクロマウス
tag:
    - マイクロマウス
    - 制御
comments: true
thumb: /images/thumb_trajectory_track_trajectory.svg
---
最近マイクロマウス界隈で話題になっている目標軌道に追従する制御について、
自分のやっていることを書きます。Part2



# 目次
これは2部構成のうちの1つ目の記事です。

1. [独立二輪車型ロボットで目標軌道に追従する制御をする①](/posts/2018-11-07-trajectory_tracking1)
2. [**独立二輪車型ロボットで目標軌道に追従する制御をする②**](/posts/2018-11-07-trajectory_tracking2)


# 自分がやっている制御
いよいよ本題です。
色々試した結果、入出力の線形化フィードバックを用いて軌道追従制御を実現しています。
制御対象に補償器を取り付けることで線形化し、線形化された制御対象に対して軌道追従を達成するコントローラを取り付けていきます。
軌道追従制御を知らない状態でこの記事を読むと、軌道追従制御はこれしかないように思えてしまうかもしれませんが、
ある1つの方法でしかないことは忘れないでください。

## 制御対象
冒頭でも出てきましたが、もう一度書いておきます。
今回は以下のような速度目標値$$u_v, u_{\omega}$$が入力、ロボットの位置$$x, y$$が出力、ロボットの姿勢$$\theta$$を内部状態にもつ制御対象$$P$$を考えます。

![](/images/trajectory_block_plant.svg){:data-action="zoom"}

制御対象$$P$$の入出力の関係は以下のように書けるとします。

$$
\begin{align}
    P : \left\{
    \begin{array}{l}
        \dot{x} &=& u_v \cos{\theta} \\
        \dot{y} &=& u_v \sin{\theta} \\
        \dot{\theta} &=& u_{\omega}
    \end{array}
    \right.
\end{align}
$$


## Step1：線形化フィードバックを作る
参考文献1で紹介されていた方法です。
下準備ですがこれが肝です。
なんでそんなのを思いついたの??となった人は参考文献を読んでください。
ここで語るのは非常に大変なので省略します。

新しい入力$$u_x, u_y$$を導入して、
$$u_x, u_y \to x,y$$が線形システムとなるような補償器$$C$$を$$P$$に取り付けます。

![](/images/trajectory_block_linearize.svg){:data-action="zoom"}

補償器$$C$$は入力が$$u_x, u_y$$、出力が$$u_v, u_{\omega}$$で、$$P$$の内部状態$$\theta$$を取得できるとします。
この補償機は内部状態$$\xi \neq 0$$($$\neq 0$$については後述)をもち、入出力と内部状態の関係は以下のようにします。

$$
\begin{align}
    C : \left\{
    \begin{array}{l}
        \dot{\xi} &=& u_x \cos{\theta} +  u_y \sin{\theta} \\
        u_v &=& \xi \\
        u_{\omega} &=& \frac{u_y \cos{\theta} - u_x \sin{\theta}}{\xi}
    \end{array}
    \right.
\end{align}
$$

制御対象$$P$$と補償器$$C$$を接続した閉ループ系を$$P_l$$とします。
驚くべきことに、補償器をとりつけることで$$P_l$$のダイナミクスは以下のようになります。

$$
\begin{align}
    P_l : \left\{
    \begin{array}{l}
        \ddot{x} &=& u_x \\
        \ddot{y} &=& u_y 
    \end{array}
    \right.
\end{align}
$$

図にするとこんな感じです。

![](/images/trajectory_block_linearize_eq.svg){:data-action="zoom"}

なんと超簡単な線形システムになってしまいました。
これの証明は$$\ddot{x}, \ddot{y}$$を計算するだけです。

$$
\begin{align}
    \begin{array}{l}
        \ddot{x} &=& -\dot{\theta} \sin{\theta} u_v + \cos{\theta} \dot{u_v} \\
                 &=& -u_{\omega} \sin{\theta} \xi + \cos{\theta} \dot{\xi} \\
                 &=& -(u_y \cos{\theta} - u_x \sin{\theta}) \sin{\theta} + \cos{\theta} (u_x \cos{\theta} + u_y \sin{\theta}) \\
                 &=& -u_y \cos{\theta} \sin{\theta} + u_x \sin^2{\theta} + u_x \cos^2{\theta} + u_y \cos{\theta} \sin{\theta} \\
                 &=& u_x
    \end{array}
\end{align}
$$

$$\ddot{y}$$も同じように計算できます。

ここまでで補償器$$C$$を使うことで$$u_x, u_y$$から$$x,y$$へのダイナミクスを線形化することができました。
しかもただ線形化されただけではなく、$$x$$のダイナミクスと$$y$$のダイナミクスも入力も完全に分離されています。

ここまで来てしまえば、後は線形システムの制御の色々が適応できるので割となんでもできます。
以降では軌道追従コントローラを作っていきます。

## Step2：軌道追従コントローラを作る
目標軌道は$$(x_r(t), y_r(t))$$でした。
ここでは先程出てきた$$\xi \neq 0$$を達成するために、いかなる時刻$$t$$においても
$$\dot{x}^2_r(t) + \dot{y}^2_r(t) \neq 0$$、つまり**並進速度が0にならない**とします。

機体の位置である$$x(t), y(t)$$をこの目標軌道に追従(収束)させるために、
以下のようなコントローラ$$K$$を取り付けます。

![](/images/trajectory_block_controller.svg){:data-action="zoom"}

コントローラ$$K$$は目標軌道$$x_r, y_r$$を入力とし、補償機への入力$$u_x, u_y$$を出力とする線形システムで、
その入出力は以下のようにします。

$$
\begin{align}
    K : \left\{
    \begin{array}{l}
        u_x &=& \ddot{x}_r + K_{x1} (\dot{x}_r - \dot{x}) + K_{y2} (x_r - x) \\
        u_y &=& \ddot{y}_r + K_{y1} (\dot{y}_r - \dot{y}) + K_{y2} (y_r - y)
    \end{array}
    \right.
\end{align}
$$

コントローラ$$K$$を取り付けたとき、$$\lim_{t \to \infty}(x_r(t) - x(t)) = 0$$となる必要十分条件は$$K$$のパラメータ$$K_{x1}, K_{x2}$$が$$K_{x1}>0, K_{x2}>0$$を満たすことです。
また、$$y$$に関しても$$\lim_{t \to \infty}(y_r(t) - y(t)) = 0$$となる必要十分条件は$$K$$のパラメータ$$K_{y1}, K_{y2}$$が$$K_{y1}>0, K_{y2}>0$$を満たすことです。

コントローラ$$K$$と線形化されたシステム$$P_l$$の閉ループ系のダイナミクス$$P_{cl}$$は次のようになります。

$$
\begin{align}
    P_{cl} : \left\{
    \begin{array}{l}
        \ddot{x} &=& \ddot{x}_r + K_{x1} (\dot{x}_r - \dot{x}) + K_{y2} (x_r - x) \\
        \ddot{y} &=& \ddot{y}_r + K_{y1} (\dot{y}_r - \dot{y}) + K_{y2} (y_r - y)
    \end{array}
    \right.
\end{align}
$$

軌道追従誤差$$e_x(t) := x_r(t) - x_r(t), \ e_y(t) := y_r(t) - y_r(t)$$を定義すると、
この追従誤差は以下のダイナミクスに従います。

$$
\begin{align}
    \left\{
    \begin{array}{l}
        \ddot{e}_x + K_{x1} \dot{e}_x + K_{x2} e_x = 0 \\
        \ddot{e}_y + K_{y1} \dot{e}_y + K_{y2} e_y = 0
    \end{array}
    \right.
\end{align}
$$

これは2次の線形微分方程式なので、
$$\lim_{t \to \infty} e_x(t) = 0$$となる必要十分条件は$$K_{x1} > 0$$かつ$$K_{x2} > 0$$で、
$$\lim_{t \to \infty} e_y(t) = 0$$となる必要十分条件は$$K_{y1} > 0$$かつ$$K_{y2} > 0$$です。

とりあえず制御パラメータ$$K_{x1}, K_{x2}, K_{y1}, K_{y2}$$は正に選んでおけば軌道追従を達成できるというわけです。
しかも追従誤差が式(8)のダイナミクスに従うわけですから、追従誤差が指数関数的に減少するような制御(指数安定)が可能です。

安定性以外の制御性能に関しても線形の2次系と同様に考えることができます。
2次系を考えることで制御パラメータをとにかく収束が速くなるものに選んだり、
オーバーシュートがでないように選んだりすることができます。

ここまでで紹介した方法のポイントは、補償器をとりつけることで制御系の入出力を線形化していることです。
一般的に非線形制御で安定性に加えて制御性能まで議論をすることを難しいのですが、
制御対象を一旦線形化することで線形制御の道具達を活用できることが最大の特徴です。


## 問題点
### $$\xi = 0$$が特異点になっている
補償器$$C$$の内部状態$$\xi$$は0になってはいけません。
自ずと$$\xi = 0$$になるのではなく、$$\xi = 0$$となるようにケアしてやらないといけないのです。
私はそれを達成するために、速度が閾値以上の領域ではここまでで紹介した方法で制御を行い、
閾値以下の領域では目標速度をフィードフォワード的に与えるだけにしています。

### 内部状態$$\theta, \xi$$の安定性(有界性)は？
自分は証明できていません。
参考文献1にはこの手法の詳細はSpringerの本に書いてるとあるのですが、
Springerの本が入手できていないので(高い!!)先見の明も得られない状態です。

# 実装してみた
今作っているマイクロマウスのハーフサイズ競技用のマシンには、ここまでで紹介した軌道追従制御を実装しています。
ちゃんと走っているので、この記事で紹介した方法はある程度有用なものではないかと思います。

<blockquote class="twitter-tweet" data-lang="ja"><p lang="ja" dir="ltr">マウス氏、速くなった <a href="https://t.co/Bvo8UNxJYn">pic.twitter.com/Bvo8UNxJYn</a></p>&mdash; id (@idt12312) <a href="https://twitter.com/idt12312/status/1055454766178828289?ref_src=twsrc%5Etfw">2018年10月25日</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>



## 参考資料
軌道追従制御、特に以降で紹介する制御に関して情報を得るのに役立った資料です。

[**1. Control of Wheeled Mobile Robots: An Experimental Overview**](https://link.springer.com/chapter/10.1007/3-540-45000-9_8)<br>
これは[SpringerのRamsete:Articulated and Mobile Robotics for Services and Technologies](https://www.researchgate.net/publication/321620382_Ramsete_Articulated_and_Mobile_Robotics_for_Services_and_Technologies)
という本の一つの章です。運良くResearchGateで無償公開されていました。
以降出てくる、私自身がマイクロマウスの機体に実装している制御手法はこの文献に書いてあったものです。


[**2. 三平研究室：講義資料**](http://www.sl.sc.e.titech.ac.jp/SCHP/tool.html)<br>
微分幾何学に基づいた非線形制御理論についての基礎的な部分がまとめてある資料達です。
学校の授業でこういう分野があることを知り、まずはこのあたりの資料を中心に勉強しました。

[**3. A stable tracking control method for an autonomous mobile robot**](https://ieeexplore.ieee.org/document/126006)<br>
話はそれますが、今回紹介する方法とは違った制御手法のものです。
イメージもしやすく、安定性の証明も実装も非常に簡単なので最初はこの方法を使っていました。
ただ、漸近安定までしか証明できないせいか、マイクロマウスではカーブ直後にどうしてもふらつくような感じがしたので使うのをやめてしまいました。
パラメータがだめなだけだったかも知れないです。

