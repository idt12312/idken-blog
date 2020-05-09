docker run --rm --name=jekyll --volume="$PWD":/srv/jekyll --volume="$PWD"/vendor/bundle:/usr/local/bundle -it -p 4000:4000 jekyll/jekyll jekyll serve --incremental
