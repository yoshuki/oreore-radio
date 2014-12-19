Copyright
==========

Copyright (c) 2012-2014 MIKAMI Yoshiyuki. See LICENSE for details.

How to use
==========

1. `% brew install taglib`
2. `% cd $HOME/Desktop/`
3. `% git clone https://github.com/yoshuki/oreore-radio.git`
4. `% cd oreore-radio`
5. `` % bundle config build.taglib-ruby --with-opt-dir=`brew --prefix` ``
6. `% bundle install --path vendor/bundle`
7. Put "\*\_YYYYMMDD.mp3" into "radio\_new/" and "\*.jpg" into "images/" as front cover.
8. Copy "config.yml.sample" to "config.yml" and update with your environment.
9. `% bundle exec rake oreore:prepare`
10. `% bundle exec rake oreore:podcast`
11. Podcast will be created as "rss.xml", under "url.base" specified in "config.yml".
