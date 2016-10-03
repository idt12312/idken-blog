---
layout: post
title: MPLABXのプロジェクトをgitでいい感じに管理する
category: pic
tag:
    - pic
    - mplab
    - git
comments: true
---

今回はPICの公式開発用IDEであるMPLABXのプロジェクトをgitでいい感じに管理をすることを考えます。

<!-- more -->

そもそもコードさえ管理しておけばいいのではないかと思われるかもしれませんが、
もしコードだけをgitで管理してチームで共有(Githubなどで)していた場合、
他の人はMPLABXのプロジェクトをいちいち作らないとビルドしてデバッグしたりすることができません。

gitでMPLABXのプロジェクトごと管理してしまえば、
リポジトリをcloneしたらすぐにIDEにプロジェクトを取り込んでビルドをしたりすることができます。

またビルド時の細かい設定などはプロジェクトファイルに含まれているので、
プロジェクトファイルごと管理をすることは同じ環境を再現するという点からも意味があります。

単純にgitにプロジェクトファイルの全てを管理させたらいいのかというとそうでもありません。
プロジェクトファイルの内にはMPLABXの起動時やビルドの時にだけ作成・更新されるファイルも幾つかあり、
それらもgitの管理下に置いてしまうと毎回commitに紛れ込んでとても邪魔になります。

そこで今回はプロジェクトを(正常に)開くために最低限必要なファイルを調査し、
いい感じの.gitignoreを考えてみました。

ちなみにMPLBXはバージョン3.30を使用しています。

<br/>

# 最低限必要なファイル
今回関係するファイルたちは次のようなディレクトリ構造になっているとします。
コードはsrcとincに分けて入れてあり、プロジェクトファイルたちがまとまっているPicProject.Xとは分けています。

* PicProject
	* .git
	* .gitignore
	* src/
	* inc/
	* PicProject.X/

MPLABX上でビルドやデバッグをしているとPicProject.Xの中身は次のようになると思います。

* PicProject.X/
	* build/
	* ・・・
	* funclist
	* l.obj
	* Makefile
	* nbproject/
		* ・・・
		* private/
			* ・・・

ここからファイルを消してはMPLABXでプロジェクトが開けるかをひたすら試した結果、
次の3つのファイルさえあればプロジェクトの設定を保存しつつプロジェクトとして開けることがわかりました。

* PicProject.X/
	* Makefile
	* nbproject/
		* configuration.xml
		* project.xml

他のファイルはビルド時やプロジェクトを開いた時に毎回生成されるものなので、
消してしまっても問題ありません。

project.xmlはそもそもプロジェクトとして認識されるのに必要で、
configuration.xmlにはプロジェクトの設定
(プロジェクトに含まれるソースコード一覧・PICkitの設定・ビルドオプションなど)
が書かれています。
Makefileはないとビルドができなくなりました。(プロジェクト新規作成時に一度だけ生成される?)


<br/>

# プロジェクトをgitで管理する
MPLABXのプロジェクトに最低限必要なファイルがわかりましたので、
gitで管理しやすくするために必要でないファイルを除外するような.gitignoreを考えます。

.gitignoreの振る舞いを調べつつ色々試した結果、.gitignoreはこんな感じになりました。

```
PicProject.X/*
!PicProject.X/Makefile
!PicProject.X/nbproject
PicProject.X/nbproject/*
!PicProject.X/nbproject/configurations.xml
!PicProject.X/nbproject/project.xml
```

.gitignoreでは.gitignoreが置かれたディレクトリから1階層の深さまでであれば簡単に設定ができるのですが、
2階層以上の深さになると煩雑になります。
.gitignoreを複数のディレクトリにおく方法もあるらしいのですが、
プロジェクトファイルの中におくのはなんか気持ち悪いのと、
設定ファイルが複数に別れるのが嫌いなのでその方法はとりませんでした。


