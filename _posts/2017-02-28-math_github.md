---
layout: post
title: GithubのREADMEとかwikiで数式を書く
category: ソフトウェア
tag:
    - ソフトウェア
    - Github
    - git
comments: true
thumb: https://assets-cdn.github.com/images/modules/logos_page/GitHub-Mark.png
---
Githubで考える限り一番便利に数式を表示する方法


GithubのREADMEやwikiで数式を書きたいことが多々ありますが、どうも簡単にはできないっぽいです。
[Qiitaみたい](http://qiita.com/PlanetMeron/items/63ac58898541cbe81ada)に書いてみてもレンダリングはされず、Mathjaxのようなjava scriptもgithub上では実行できないみたいです。


# 解決策：latexの画像化サービスを使う
基本的には数式を画像化して貼るという作戦になります。
ただ、[Texclip](https://texclip.marutank.net/)みたいなサービスを使って
毎回数式をtex記法で打って画像化して貼ってを繰り返していては面倒です。
少し間違えてしまった時などには、再び画像を出力して画像ファイルを差し替える操作が必要になってしまいます。

そこで、このサービスを利用します。

[CODECOGS](https://www.codecogs.com/latex/eqneditor.php)

![](/images/math_github_codecogs.png){:data-action="zoom"}

見た目はTexclipなどと同じ感じですが、一番の違いは画面の下の方に数式の画像を出すためのURLを出してくれるところです。

![](/images/math_github_url.png){:data-action="zoom"}

ここのURLをみるとすぐにわかると思うのですが、リクエストにtex記法での数式を書くと画像が返ってくるという仕組みになっています。
なのでこのURLを画像としてmarkdown貼り付けてやれば数式を表示できます。

例えばMarkdownに

```html
<img src="https://latex.codecogs.com/gif.latex?\int_a^bf(x)dx" />
```

と書いた場合は

<img src="https://latex.codecogs.com/gif.latex?\int_a^bf(x)dx" style="width: 80px;"/>

のように表示できます。

画像を貼り付けているのですが、自分で画像ファイルを用意するのではなくURLを叩いて画像を生成しているので、
数式を少し編集したい場合にはURLのリクエストの部分を書き換えるだけでOKです。

Markdownなら

```markdown
![alt](url title)
```

の形式で書きたいところですが、これで書くとなぜかGithubではうまく表示できませんでした。
たぶんURLのエスケープ周りの問題だと思うのでURLをエンコードすればいいのですが、そうすると数式を少し修正するときにURLを編集するという
今回やりたかったことができなくなってしまうので、HTMLのタグをそのまま書くことにしました。


# 実際にGithub上で使ってみた
私のGithubのとあるリポジトリのREADME.mdで数式を使いたい場面があり、
こんな感じでQiitaみたいに書いていました。

```markdown
受光した信号を$$x[k] (k=1 \dots N)$$、サンプリング周波数を$$F_s$$とします。  
ここでは$$x[n]$$から周波数$$F_s \frac{n}{N}\ (n \in \mathbb{N})$$成分の強度を計算するとします。  

まず
$$
	X[n] = \sum_{k=0}^{N-1}x[k]\exp({-j\frac{2 \pi nk}{N}})
$$
を計算します。  

次に$$X[n] \in \mathbb{C}$$の絶対値を計算することで  
$$x[k]$$に含まれる周波数$$F_s \frac{n}{N}$$の振幅を得ることができます。
```

これはGithub上ではこのように表示されます。

<img src="/images/math_github_before.png"  style="width: 600px;border:solid 3px #000000;"/>

ちゃんと数式として表示されていません。

markdownの数式の部分を先ほどのHTMLのimgタグに置き換えます。

```markdown
受光した信号を
<img src="https://latex.codecogs.com/gif.latex?\inline&space;x[k]\&space;(k=1&space;\dots&space;N)" />
、サンプリング周波数を
<img src="https://latex.codecogs.com/gif.latex?\inline&space;F_s" />
とします。  
ここでは
<img src="https://latex.codecogs.com/gif.latex?\inline&space;x[n]" />
から周波数
<img src="https://latex.codecogs.com/gif.latex?\inline&space;F_s&space;\frac{n}{N}\&space;(n&space;\in&space;\mathbb{N})" />
成分の強度を計算するとします。  

まず

<img src="https://latex.codecogs.com/gif.latex?X[n]&space;=&space;\sum_{k=0}^{N-1}x[k]\exp({-j\frac{2&space;\pi&space;nk}{N}})"/>

を計算します。  

次に
<img src="https://latex.codecogs.com/gif.latex?\inline&space;X[n]&space;\in&space;\mathbb{C}" />
の絶対値を計算することで  
<img src="https://latex.codecogs.com/gif.latex?\inline&space;x[k]" />
に含まれる周波数
<img src="https://latex.codecogs.com/gif.latex?\inline&space;F_s\frac{n}{N}" />
の振幅を得ることができます。
```

そうするとGithub上ではこのように表示されます。

<img src="/images/math_github_after.png"  style="width: 500px;border:solid 3px #000000;"/>

文章中の数式は微妙な感じですが、ひとまず表示はできます。

ちなみに文章中の数式はCODECOGSでinline指定をするとこんな感じで小さく表示できます。


# 結論
本当はQiitaみたいにかけたらいいのですが、texclipみたいに画像ファイルを生成しまくるよりはましな方法という感じです。

