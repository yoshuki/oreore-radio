How to use
==========

1. `` % cd `brew --prefix` ``
2. `% curl https://raw.github.com/gist/3756296/b6e91736c9ecba474d115798b92c7cf4994fb5b8/id3lib.patch | patch -p0`
3. `% brew install id3lib`
4. `% git clone https://github.com/yoshuki/oreore-radio.git`
5. `% cd oreore-radio`
6. `` % bundle config build.id3lib-ruby --with-opt-dir=`brew --prefix` ``
7. `% bundle install --path vendor/bundle`
8. `% bundle exec oreore_podcast.rb`
