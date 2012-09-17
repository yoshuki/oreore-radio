# coding: utf-8

require 'fileutils'
require 'rss'
require 'uri'

require 'id3lib'
require 'net/scp'

DIR_BASE      = File.expand_path(File.dirname(__FILE__))
DIR_IMAGES    = "#{DIR_BASE}/images"
DIR_RADIO_NEW = "#{DIR_BASE}/radio_new"
DIR_RADIO     = "#{DIR_BASE}/radio"
DIR_TMP       = "#{DIR_BASE}/tmp"

CONFIG = YAML.load_file("#{DIR_BASE}/config.yml")

SSH_HOST = CONFIG['ssh']['host']
SSH_USER = CONFIG['ssh']['user']
SSH_PATH = CONFIG['ssh']['path']

URL_BASE = CONFIG['url']['base']

def embed_cover_image(mp3_file)
  image_file = "#{DIR_IMAGES}/#{File.basename(mp3_file, '.mp3').split('_').first}.jpg"
  image_file = "#{DIR_IMAGES}/logo_tbsradio.jpg" unless File.exist?(image_file)

  tag = ID3Lib::Tag.new(mp3_file)
  unless tag.any? {|t| t[:id] == :APIC }
    tag << {
        :id          => :APIC,
        :textenc     => 0,
        :mimetype    => 'image/jpeg',
        :picturetype => 3,
        :description => 'TBS RADIO 954kHz',
        :data        => File.read(image_file)
      }
    tag.update!
  end
end

def encode_to_utf_8(source)
  return source if source.encoding == Encoding::UTF_8
  source.encode(Encoding::UTF_8, Encoding::UTF_16BE, invalid: :replace)
end

def create_podcast_rss
  RSS::Maker.make('2.0') {|maker|
    maker.channel.language = 'ja'
    maker.channel.link = "#{URL_BASE}/"
    maker.channel.title = 'オレオレTBSラジオ'
    maker.channel.description = 'オレオレTBSラジオポッドキャストです。'

    maker.items.do_sort = true

    maker.image.title = 'TBS RADIO 954kHz'
    maker.image.url = "#{URL_BASE}/logo_tbsradio.gif"

    Dir::glob("#{DIR_RADIO}/*.mp3") do |mp3_file|
      item = maker.items.new_item

      item.date = File.mtime(mp3_file)
      item.enclosure.url = "#{URL_BASE}/mp3/#{URI.escape(File.basename(mp3_file))}"
      item.enclosure.length = File.size(mp3_file)
      item.enclosure.type = 'audio/mpeg'

      tag = ID3Lib::Tag.new(mp3_file)

      item.title = encode_to_utf_8(tag.title)
      item.author = encode_to_utf_8(tag.artist)

      album = encode_to_utf_8(tag.album)
      genre = encode_to_utf_8(tag.genre)
      item.itunes_subtitle = "#{genre} #{album}"
    end
  }.to_s
end

if __FILE__ == $0
  # Embed cover image and upload mp3
  Dir::glob("#{DIR_RADIO_NEW}/*.mp3") do |mp3_file|
    embed_cover_image(mp3_file)
    Net::SCP.upload!(SSH_HOST, SSH_USER, mp3_file, "#{SSH_PATH}/mp3/")
    FileUtils.move(mp3_file, DIR_RADIO)
  end

  # Clean expired mp3
  Net::SSH.start(SSH_HOST, SSH_USER) do |ssh|
    Dir::glob("#{DIR_RADIO}/*.mp3") do |mp3_file|
      limit = (Time.now - (86400*14)).strftime('%Y%m%d')
      if File.basename(mp3_file, '.mp3').split('_').last < limit
        File.delete(mp3_file)
        ssh.exec!("rm -f #{SSH_PATH}/mp3/#{File.basename(mp3_file)}")
      end
    end
  end

  # Create and upload podcast rss
  rss_file = "#{DIR_TMP}/rss.xml"
  File.open(rss_file, 'w') {|f| f.puts create_podcast_rss }
  Net::SCP.upload!(SSH_HOST, SSH_USER, rss_file, "#{SSH_PATH}/")
end
