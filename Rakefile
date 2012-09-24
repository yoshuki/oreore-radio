# coding: utf-8

require 'net/scp'

DIR_BASE   = File.expand_path(File.dirname(__FILE__))
DIR_IMAGES = "#{DIR_BASE}/images"

CONFIG = YAML.load_file("#{DIR_BASE}/config.yml")

SSH_HOST = CONFIG['ssh']['host']
SSH_USER = CONFIG['ssh']['user']
SSH_PATH = CONFIG['ssh']['path']

namespace :oreore do
  desc 'Prepare to oreore-radio.'
  task :prepare do
    Net::SSH.start(SSH_HOST, SSH_USER) do |ssh|
      ssh.exec!("mkdir -p #{SSH_PATH}/mp3/")
    end
    Net::SCP.upload!(SSH_HOST, SSH_USER, "#{DIR_IMAGES}/logo_tbsradio.jpg", "#{SSH_PATH}/")
  end
end
