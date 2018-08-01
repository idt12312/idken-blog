---
layout: post
title: QNAP NASでRedmineを動かす
category: ソフトウェア
tag:
    - ソフトウェア
    - NAS
comments: true
thumb: /images/thumb_default.svg
---
以前PCやスマホのバックアップ用にQNAPのNASを購入しました。
このNASではDockerが利用できるので、その上にRedmineを入れて動かしてみました。


# 家にあるNASについて
まずは家にあるNASを紹介します。

2年前くらいにPCとスマホのバックアップ用に[QNAPのTS-231+](https://amzn.to/2LKWHwL)というNASを購入しました。
これは3.5インチのHDD(別売)を2つ搭載できます。
NASとして使いつつ、**汎用サーバー(ARM & Linux)としても使える**のが嬉しいポイントです。

<div class="amazlet-box" style="margin-bottom:0px;"><div class="amazlet-image" style="float:left;margin:0px 12px 1px 0px;"><a href="http://www.amazon.co.jp/exec/obidos/ASIN/B01N78FRVZ/idt12312-22/ref=nosim/" name="amazletlink" target="_blank"><img src="https://images-fe.ssl-images-amazon.com/images/I/41dQATyZPvL._SL160_.jpg" alt="QNAP(キューナップ) TS-231P 専用OS QTS搭載 デュアルコア1.7GHz CPU 1GBメモリ 2ベイ ホーム&SOHO向け スナップショット機能対応 NAS 2年保証" style="border: none;" /></a></div><div class="amazlet-info" style="line-height:120%; margin-bottom: 10px"><div class="amazlet-name" style="margin-bottom:10px;line-height:120%"><a href="http://www.amazon.co.jp/exec/obidos/ASIN/B01N78FRVZ/idt12312-22/ref=nosim/" name="amazletlink" target="_blank">QNAP(キューナップ) TS-231P 専用OS QTS搭載 デュアルコア1.7GHz CPU 1GBメモリ 2ベイ ホーム&SOHO向け スナップショット機能対応 NAS 2年保証</a><div class="amazlet-powered-date" style="font-size:80%;margin-top:5px;line-height:120%">posted with <a href="http://www.amazlet.com/" title="amazlet" target="_blank">amazlet</a> at 18.07.31</div></div><div class="amazlet-detail">QNAP(キューナップ) (2016-12-09)<br />売り上げランキング: 1,277<br /></div><div class="amazlet-sub-info" style="float: left;"><div class="amazlet-link" style="margin-top: 5px"><a href="http://www.amazon.co.jp/exec/obidos/ASIN/B01N78FRVZ/idt12312-22/ref=nosim/" name="amazletlink" target="_blank">Amazon.co.jpで詳細を見る</a></div></div></div><div class="amazlet-footer" style="clear: left"></div></div>

HDDにはWD Redの3TBのを2つ購入しました。

<div class="amazlet-box" style="margin-bottom:0px;"><div class="amazlet-image" style="float:left;margin:0px 12px 1px 0px;"><a href="http://www.amazon.co.jp/exec/obidos/ASIN/B008P56QEQ/idt12312-22/ref=nosim/" name="amazletlink" target="_blank"><img src="https://images-fe.ssl-images-amazon.com/images/I/51I6hfSzvyL._SL160_.jpg" alt="WD HDD 内蔵ハードディスク 3.5インチ 3TB WD Red NAS用 WD30EFRX 5400rpm 3年保証" style="border: none;" /></a></div><div class="amazlet-info" style="line-height:120%; margin-bottom: 10px"><div class="amazlet-name" style="margin-bottom:10px;line-height:120%"><a href="http://www.amazon.co.jp/exec/obidos/ASIN/B008P56QEQ/idt12312-22/ref=nosim/" name="amazletlink" target="_blank">WD HDD 内蔵ハードディスク 3.5インチ 3TB WD Red NAS用 WD30EFRX 5400rpm 3年保証</a><div class="amazlet-powered-date" style="font-size:80%;margin-top:5px;line-height:120%">posted with <a href="http://www.amazlet.com/" title="amazlet" target="_blank">amazlet</a> at 18.07.31</div></div><div class="amazlet-detail">Western Digital <br />売り上げランキング: 250<br /></div><div class="amazlet-sub-info" style="float: left;"><div class="amazlet-link" style="margin-top: 5px"><a href="http://www.amazon.co.jp/exec/obidos/ASIN/B008P56QEQ/idt12312-22/ref=nosim/" name="amazletlink" target="_blank">Amazon.co.jpで詳細を見る</a></div></div></div><div class="amazlet-footer" style="clear: left"></div></div>


基本的にはPCとスマホのバックアップに使っています。
WindowsPCからは、Windowsの「ファイル履歴」の機能を使ってこのNASにバックアップを取っています。
このNASはAppleのTimemachineにもなるので、MacBookを使っていた時はこのTimemachineの機能を使ってバックアップを取っていました。

QNAPのNASはスマホともうまく連携できるように、スマホ用のQNAPのアプリがあります。
このアプリを使うことで、スマホが家のWifiにつながったら、
スマホカメラで撮影した画像や動画を自動でNASにアップロードすることが可能となっています。
wifiの検出やアップロードはバッグブランドで自動的に行われるので非常に快適です。

myQNAPcloudというものを使うと、簡単な設定のみで外部のネットワークからアクセスすることもできます。
出先でNASの中身を見たりuploadしたりするだけではなく、DropBoxやGoogleDriveのように共有用のリンクを作成することもできます。
つまり家のNASを自分専用のDropBoxみたいなサーバーとして使うことができるのです。

ブラウザから見える管理用のページはこんな感じで、QNAP専用のアプリを入れたり操作をすることで機能の追加や
管理ができるようになっています。

![](/images/qnap_control.png){:data-action="zoom"}

ここまでの基本機能だけも十分に便利に使えていたのですが、
実はNAS上にContainer Stationというアプリ(中身はDocker)があり、
Dockerのコンテナを動かせることに最近気付きました。
この機能によって、NASというよりは**家用簡単サーバー**として使うことができるのです。
Dockerのコンテナが使えるだけでも色んな環境の導入が楽にでき、
加えてそれらがGUI上から簡単に扱えるようになっているのが個人的にはとても気に入っています。

RaspberryPIや安いPCをベースに自宅サーバーを立てても同じことはできます。
その中でQNAPのNASを汎用サーバーっぽく使うことのメリットは、
* そもそもNASとして十分な機能を使える
* 動作が安定している
* 省電力である

という点だと思います。


# 今回やったこと
今回はこのContainer Stationを使ってRedmineをNAS上で動かしました。

手順としてはこんな感じです。

1. ContainerStatiobをインストールする
2. Container Station上にRedmineをインストールする

基本的にはDockerのイメージを入れるだけなのですが、
一つ注意が必要となります。
それは**ARM上で動くイメージを選ぶ必要がある**ということです。
TS-231+のCPUはARMで、Alpine LinuxというOSが動いています。
コンテナイメージを検索するときに"arm armv7 armhf"とかを入れて検索すると、
TS-231+でもちゃんと動くものが見つけられます。

## Container Stationをインストールする
QNAPのAppCenterからContainer Stationをインストールします。

![](/images/qnap_install_container_station.png){:data-action="zoom"}

Container Stationではコンテナのインストールや管理をGUIから簡単に行うことができます。

![](/images/qnap_container_station.png){:data-action="zoom"}


## コンテナを作成する
Dockerをいじろうとするとコマンドを打って色々作業が必要となるのですが、
Container Stationではボタンをポチポチしているだけでコンテナが立ち上がります。

Redmineのためのイメージとしては、Redmine公式のイメージを使いました。
コンテナイメージはContainerStaionの"作成"タブのところから検索できます。
検索はQNAP公式のものだけではなく、DockerHubからも検索されます。
今回インストールしたのはredmineで検索すると出てくる公式っぽいやつです。

![](/images/qnap_search_redmine.png){:data-action="zoom"}


インストールボタンを押すと色々聞かれますが、デフォルト設定で動きました。
コンテナの作成は一瞬でできました。
コンテナが作成されるとすぐにRedmineが立ち上がるわけではなく、
コンテナ内でRedmineのセットアップが行われます。
自分の環境では10分くらいかかった気がします。
セットアップが完了するとRedmineが立ち上がり、
Container Stationのコンテナの詳細画面にURLが表示されます。

![](/images/qnap_control_redmine.png){:data-action="zoom"}

このURLにアクセスするとRedmineの画面が出ます。


# まとめ
QNAPではContainer Stationを使うことでDockerコンテナを作成することができ、
それを使ってRedmineを動かすことができました。
Dockerイメージがあれば何でもできるのですが、唯一注意しないといけないのは
**ARMで動くイメージを選ばないといけない**ということです。

実はGitlabを入れようとしてみました。
しかしメモリが足りずに動作がとても重くなってしまいました。
Gitlabはメモリをswapと合わせて4GB以上与えることが推奨されているののに対して、
今回のNASは1GBしか載っていないのが原因みたいです。
