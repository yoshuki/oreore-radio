# coding: utf-8

require 'fileutils'
require 'rss'
require 'uri'
require 'yaml'

require 'net/scp'
require 'taglib'

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

def files_sorted_by_mtime(pattern)
  Dir.glob(pattern).map{|f| [File.mtime(f), f] }.sort{|a, b| a.first <=> b.first }.map(&:last)
end

def embed_cover_image(mp3_file)
  image_file = "#{DIR_IMAGES}/#{File.basename(mp3_file, '.mp3').split('_').first}.jpg"
  image_file = "#{DIR_IMAGES}/logo_tbsradio.jpg" unless File.exist?(image_file)

  TagLib::MPEG::File.open(mp3_file) do |file|
    tag = file.id3v2_tag

    unless tag.frame_list.any? {|f| f.is_a?(TagLib::ID3v2::AttachedPictureFrame) }
      apic = TagLib::ID3v2::AttachedPictureFrame.new
      apic.mime_type = 'image/jpeg'
      apic.description = 'Front Cover'
      apic.type = TagLib::ID3v2::AttachedPictureFrame::FrontCover
      apic.picture = File.read(image_file)
      tag.add_frame(apic)

      file.save
    end
  end
end

def create_podcast_rss
  RSS::Maker.make('2.0') {|maker|
    maker.channel.language = 'ja'
    maker.channel.link = "#{URL_BASE}/"
    maker.channel.title = 'オレオレTBSラジオ'
    maker.channel.description = 'オレオレTBSラジオポッドキャストです。'

    maker.items.do_sort = true

    maker.image.title = 'TBS RADIO 954kHz'
    maker.image.url = "#{URL_BASE}/logo_tbsradio.jpg"

    files_sorted_by_mtime("#{DIR_RADIO}/*.mp3").each do |mp3_file|
      item = maker.items.new_item

      item.date = File.mtime(mp3_file)
      item.enclosure.url = "#{URL_BASE}/mp3/#{URI.escape(File.basename(mp3_file))}"
      item.enclosure.length = File.size(mp3_file)
      item.enclosure.type = 'audio/mpeg'

      TagLib::MPEG::File.open(mp3_file) do |file|
        tag = file.id3v2_tag

        item.title = tag.title || File.basename(mp3_file, '.mp3')
        item.author = tag.artist || File.basename(mp3_file, '.mp3')
        item.itunes_subtitle = "#{tag.genre} #{tag.album}".strip
      end
    end
  }.to_s
end

namespace :oreore do
  desc 'Prepare to podcast.'
  task :prepare do
    Net::SSH.start(SSH_HOST, SSH_USER) do |ssh|
      ssh.exec!("mkdir -p #{SSH_PATH}/mp3/")
    end
    Net::SCP.upload!(SSH_HOST, SSH_USER, "#{DIR_IMAGES}/logo_tbsradio.jpg", "#{SSH_PATH}/")
  end

  desc 'Update podcast.'
  task :podcast do
    # Embed cover image and upload mp3
    files_sorted_by_mtime("#{DIR_RADIO_NEW}/*.mp3").each do |mp3_file|
      embed_cover_image(mp3_file)
      Net::SCP.upload!(SSH_HOST, SSH_USER, mp3_file, "#{SSH_PATH}/mp3/")
      FileUtils.move(mp3_file, DIR_RADIO)
    end

    # Clean expired mp3
    Net::SSH.start(SSH_HOST, SSH_USER) do |ssh|
      files_sorted_by_mtime("#{DIR_RADIO}/*.mp3").each do |mp3_file|
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
end