require 'erb'
require 'fileutils'
require 'yaml'

require 'net/scp'
require 'rss'
require 'taglib'

DIR_BASE      = File.expand_path(File.dirname(__FILE__))
DIR_IMAGES    = "#{DIR_BASE}/images"
DIR_RADIO_NEW = "#{DIR_BASE}/radio_new"
DIR_RADIO     = "#{DIR_BASE}/radio"
DIR_TMP       = "#{DIR_BASE}/tmp"

CONFIG = YAML.load_file("#{DIR_BASE}/config/config.yml")

SSH_HOST = CONFIG['ssh']['host']
SSH_USER = CONFIG['ssh']['user']
SSH_PATH = CONFIG['ssh']['path']

URL_BASE = CONFIG['url']['base']

def files_sorted_by_mtime(pattern)
  Dir.glob(pattern).map{|f| [File.mtime(f), f] }.sort{|a, b| a.first <=> b.first }.map(&:last)
end

def embed_cover_image(mp3_file)
  image_file = "#{DIR_IMAGES}/#{File.basename(mp3_file, '.mp3').split('_').first}.jpg"
  image_file = "#{DIR_IMAGES}/logo_radio.jpg" unless File.exist?(image_file)

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
    maker.channel.title = 'オレオレラジオ'
    maker.channel.link = "#{URL_BASE}/"
    maker.channel.language = 'ja'
    maker.channel.description = 'オレオレラジオポッドキャストです。'
    maker.channel.itunes_subtitle = 'いやぁ、ラジオって本当にいいもんですね。'
    maker.channel.itunes_author = 'オレオレ'
    maker.channel.itunes_summary = 'オレオレラジオポッドキャストです。'

    maker.items.do_sort = true

    maker.image.title = 'RADIO'
    maker.image.url = "#{URL_BASE}/logo_radio.jpg"

    files_sorted_by_mtime("#{DIR_RADIO}/*.mp3").each do |mp3_file|
      mp3_file = Pathname.new(mp3_file)

      item = maker.items.new_item

      item.date = if (matched = mp3_file.basename('.mp3').to_s.match(/(?<=_)\d{14}\z/))
                    DateTime.strptime("#{matched}+0900", '%Y%m%d%H%M%S%Z').to_time
                  else
                    mp3_file.mtime
                  end
      item.enclosure.url = "#{URL_BASE}/mp3/#{ERB::Util.u(mp3_file.basename.to_s)}"
      item.enclosure.length = mp3_file.size
      item.enclosure.type = 'audio/mpeg'

      TagLib::MPEG::File.open(mp3_file.to_s) do |file|
        tag = file.id3v2_tag

        item.title = tag.title || mp3_file.basename('.mp3')
        item.author = tag.artist || mp3_file.basename('.mp3')
        item.description = %!<p>#{tag.album} <a href="http://radiko.jp/share/?sid=TBS&t=#{item.date.strftime('%Y%m%d%H%M%S')}">タイムフリー</a></p>!
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
    Net::SCP.upload!(SSH_HOST, SSH_USER, "#{DIR_IMAGES}/logo_radio.jpg", "#{SSH_PATH}/")
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
        limit = (Time.now - (86400*485)).strftime('%Y%m%d')
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

  desc 'Import from ripdiko.'
  task :import_from_ripdiko do
    indir = Pathname.new(ENV['RIPDIKO_OUTDIR'] || "#{ENV['HOME']}/Music/Radiko")
    outdir = Pathname.new(DIR_RADIO_NEW)

    # Basename should be like "20141219010000-TBS.mp3"
    Dir.glob(indir.join '*-*.mp3').each do |mp3_file|
      mp3_file = Pathname.new(mp3_file)

      TagLib::MPEG::File.open(mp3_file.to_s) do |file|
        name = case file.id3v2_tag.title
               when /たまむすび/; 'tama954'
               when /深夜の馬鹿力/; 'ijuin'
               when /カーボーイ/; 'bakusho'
               when /不毛な議論/; 'fumou'
               when /メガネびいき/; 'megane'
               when /粋な夜電波/; 'denpa'
               when /バナナムーンGOLD/; 'banana'
               when /コント太郎/; 'elekata'
               when /日曜天国/; 'nichiten'
               when /日曜サンデー/; 'nichiyou'
               when /東京ポッド許可局/; 'tokyopod'
               when /らじおと/; 'ij'
               when /生活は踊る/; 'so'
               when /ターン！/; 'ht'
               when /星のギガボディ/; 'giga'
               when /D\.C\.GARAGE/; 'dcg'
               when /デートの時間でそ？！/; 'deso'
               when /アニニャン！/; 'ia'
               when /ヘイ！タクシー！/; 'kamataku'
               when /好奇心プラス/; 'kaeru'
               when /問わず語り/; 'edo'
               when /すっぴんしゃん/; 'suppin'
               when /Laughter Night/; 'warai954'
               when /踊り場/; 'odoriba'
               when /週末ノオト/; 'weekend'
               when /宮藤さんに言っても/; 'gc'
               when /佐久間宣行の/; 'sakuma'
               when /ON THE PLANET/; 'otp'
               when /ケツビ！/; 'elekata'
               when /これが宮治でございます/; 'miyaji905'
               when /ここがオズワルドさんち！/; 'ozu'
               when /楽屋ぞめき/; 'gakuyazomeki'
               when /夢は口に出せば叶う/; 'kanau'
               when /百年ラヂオ/; 'hyakunen'
               when /おしんり研究所/; 'oshinri'
               when /ザブトン５/; 'miyaji'
               when /スタンド・バイ・見取り図/; 'stm'
               when /A世代！ラジオ/; 'ang'
               when /かんらからから/; 'kanra'
               when /秘密諜報員/; 'minamikawa'
               when /人工知能ちょっと来い！/; 'ai'
               else 'unknown'
               end
        started_at = mp3_file.basename('.mp3').to_s.split('-').first

        mp3_file.rename outdir.join("#{name}_#{started_at}.mp3")
      end
    end
  end

  desc 'Import from ripdiru.'
  task :import_from_ripdiru do
    indir = Pathname.new(ENV['RIPDIRU_OUTDIR'] || "#{ENV['HOME']}/Music/Radiru")
    outdir = Pathname.new(DIR_RADIO_NEW)

    # Basename should be like "20150423064402-NHK2.mp3"
    Dir.glob(indir.join '*-*.mp3').each do |mp3_file|
      mp3_file = Pathname.new(mp3_file)

      TagLib::MPEG::File.open(mp3_file.to_s) do |file|
        name = case file.id3v2_tag.title
               when /ラジオ英会話/; 'kaiwa'
               else 'unknown'
               end
        started_at = mp3_file.basename('.mp3').to_s.split('-').first

        mp3_file.rename outdir.join("#{name}_#{started_at}.mp3")
      end
    end
  end
end
