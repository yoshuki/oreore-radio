# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

DIR_RBENV_BIN = "#{ENV['HOME']}/.rbenv/bin"

set :output, "#{ENV['HOME']}/oreore-radio.log"

env :PATH, ENV['PATH']

env :RIPDIKO_OUTDIR, ENV['RIPDIKO_OUTDIR'] if ENV['RIPDIKO_OUTDIR']
env :RIPDIRU_OUTDIR, ENV['RIPDIRU_OUTDIR'] if ENV['RIPDIRU_OUTDIR']

job_type :rbenv_rake, %Q!PATH="#{DIR_RBENV_BIN}:$PATH"; eval "$(rbenv init -)"; cd :path && :bundle_command rake :task --silent :output!
job_type :be_rake, 'cd :path && :bundle_command rake :task --silent :output'

def rake_method
  File.exist?(DIR_RBENV_BIN) ? :rbenv_rake : :be_rake
end

# miyaji905
every(:sunday, at: '06:05') { send rake_method, 'oreore:import_from_ripdiko' }
every(:sunday, at: '06:10') { send rake_method, 'oreore:podcast' }

# kanau
every(:sunday, at: '13:00') { send rake_method, 'oreore:import_from_ripdiko' }
every(:sunday, at: '13:05') { send rake_method, 'oreore:podcast' }

# gakuyazomeki
every(:sunday, at: '14:00') { send rake_method, 'oreore:import_from_ripdiko' }
every(:sunday, at: '14:05') { send rake_method, 'oreore:podcast' }

# gc
every(:friday, at: '21:35') { send rake_method, 'oreore:import_from_ripdiko' }
every(:friday, at: '21:40') { send rake_method, 'oreore:podcast' }

# edo
every(:friday, at: '22:05') { send rake_method, 'oreore:import_from_ripdiko' }
every(:friday, at: '22:10') { send rake_method, 'oreore:podcast' }

# kamataku, oshinri, suppin, minamikawa
every('23 35 * * 1-4') { send rake_method, 'oreore:import_from_ripdiko' }
every('23 40 * * 1-4') { send rake_method, 'oreore:podcast' }

# midnight
every('05 1 * * 2-5') { send rake_method, 'oreore:import_from_ripdiko' }
every('10 1 * * 2-5') { send rake_method, 'oreore:podcast' }

# junk
every('05 3 * * 2-6') { send rake_method, 'oreore:import_from_ripdiko' }
every('10 3 * * 2-6') { send rake_method, 'oreore:podcast' }

# tokyopod
every(:sunday, at: '02:05') { send rake_method, 'oreore:import_from_ripdiko' }
every(:sunday, at: '02:10') { send rake_method, 'oreore:podcast' }

# sakuma
every(:thursday, at: '04:35') { send rake_method, 'oreore:import_from_ripdiko' }
every(:thursday, at: '04:40') { send rake_method, 'oreore:podcast' }

# kanra
every(:sunday, at: '04:05') { send rake_method, 'oreore:import_from_ripdiko' }
every(:sunday, at: '04:10') { send rake_method, 'oreore:podcast' }
