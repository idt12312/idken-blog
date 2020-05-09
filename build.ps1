docker run --rm --name=jekyll --volume="$PWD":/srv/jekyll --volume="$PWD"/vendor/bundle:/usr/local/bundle -it jekyll/jekyll jekyll build --incremental
