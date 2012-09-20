Copyright
==========

Copyright (c) 2012 MIKAMI Yoshiyuki. See LICENSE for details.

How to use
==========

1. `` % cd `brew --prefix` ``
2. `% curl https://raw.github.com/gist/3756296/b6e91736c9ecba474d115798b92c7cf4994fb5b8/id3lib.patch | patch -p0`
3. `% brew install id3lib`
4. `% cd $HOME/Desktop/`
5. `% git clone https://github.com/yoshuki/oreore-radio.git`
6. `% cd oreore-radio`
7. `` % bundle config build.id3lib-ruby --with-opt-dir=`brew --prefix` ``
8. `% bundle install --path vendor/bundle`
9. Put "\*.mp3" into "radio\_new/" and "\*.jpg" into "images/" as cover image.
10. `% bundle exec oreore_podcast.rb`
