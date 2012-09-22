Copyright
==========

Copyright (c) 2012 MIKAMI Yoshiyuki. See LICENSE for details.

How to use
==========

1. `% brew update`
2. `` % cd `brew --prefix` ``
3. `% curl https://raw.github.com/gist/3756296/b6e91736c9ecba474d115798b92c7cf4994fb5b8/id3lib.patch | patch -p0`
4. `% brew install id3lib`
5. `% cd $HOME/Desktop/`
6. `% git clone https://github.com/yoshuki/oreore-radio.git`
7. `% cd oreore-radio`
8. `` % bundle config build.id3lib-ruby --with-opt-dir=`brew --prefix` ``
9. `% bundle install --path vendor/bundle`
10. Put "\*.mp3" into "radio\_new/" and "\*.jpg" into "images/" as cover image.
11. Copy "config-sample.yml" to "config.yml" and update with your environment.
12. `% bundle exec ruby oreore_podcast.rb`
