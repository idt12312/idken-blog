---
layout: post
title: Jekyllの新しい記事を作るスクリプト
category: このブログについて
tag:
    - jekyll
    - シェルスクリプト
comments: true
thumb: https://jekyllrb-ja.github.io/img/logo-2x.png
---
Jekyllで新しい記事ファイルをテンプレートから作るスクリプトファイルを作ってみた


Jekyllで新しい記事を書く際に、毎回記事ファイルのMarkdownのfront matterを書くのが面倒だったので、
自動で新しい記事ファイルを作るスクリプトを作ってみました。

```sh
#!/bin/sh

FILE_NAME="`date '+%Y-%m-%d'`-${1}.md"

touch _posts/$FILE_NAME

echo \
"---
layout: post
title: $2
category: $3
tag:
    - $4
comments: true
thumb: /images/thumb_default.svg
---
" > _posts/$FILE_NAME
```

使うときは

```sh
./new_post 記事ファイル名 記事タイトル カテゴリ タグ
```

みたいにします。
実行したときの日付を入れたファイルを_postsディレクトリ下に生成してくれます。