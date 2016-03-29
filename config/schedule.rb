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

set :output, nil

env :RIPDIKO_OUTDIR, ENV['RIPDIKO_OUTDIR'] if ENV['RIPDIKO_OUTDIR']
env :RIPDIRU_OUTDIR, ENV['RIPDIRU_OUTDIR'] if ENV['RIPDIRU_OUTDIR']

job_type :rbenv_rake, %q!PATH="$HOME/.rbenv/bin:$PATH"; eval "$(rbenv init -)"; cd :path && :bundle_command rake :task --silent :output!
job_type :be_rake, 'cd :path && :bundle_command rake :task --silent :output'

def rake_method
  File.exist?("#{ENV['HOME']}/.rbenv/bin") ? :rbenv_rake : :be_rake
end

# junk
every '05 3 * * 0,2-6' { send rake_method, 'oreore:import_from_ripdiko' }
every '10 3 * * 0,2-6' { send rake_method, 'oreore:podcast' }

# paka
every :saturday, at: '16:55' { send rake_method, 'oreore:import_from_ripdiko' }
every :saturday, at: '17:00' { send rake_method, 'oreore:podcast' }

# deso
every :saturday, at: '21:05' { send rake_method, 'oreore:import_from_ripdiko' }
every :saturday, at: '21:15' { send rake_method, 'oreore:podcast' }

# ij
every '05 11 * * 1-4' { send rake_method, 'oreore:import_from_ripdiko' }
every '15 11 * * 1-4' { send rake_method, 'oreore:podcast' }

# so
every '05 13 * * 1-5' { send rake_method, 'oreore:import_from_ripdiko' }
every '15 13 * * 1-5' { send rake_method, 'oreore:podcast' }

# tama954
every '35 15 * * 1-5' { send rake_method, 'oreore:import_from_ripdiko' }
every '40 15 * * 1-5' { send rake_method, 'oreore:podcast' }

# nichiten
every :sunday, at: '12:00' { send rake_method, 'oreore:import_from_ripdiko' }
every :sunday, at: '12:05' { send rake_method, 'oreore:podcast' }

# denpa
every :saturday, at: '01:05' { send rake_method, 'oreore:import_from_ripdiko' }
every :saturday, at: '01:10' { send rake_method, 'oreore:podcast' }

# warai954
every :sunday, at: '00:35' { send rake_method, 'oreore:import_from_ripdiko' }
every :sunday, at: '00:40' { send rake_method, 'oreore:podcast' }

# tokyopod
every :sunday, at: '04:05' { send rake_method, 'oreore:import_from_ripdiko' }
every :sunday, at: '04:10' { send rake_method, 'oreore:podcast' }

# debu
every :sunday, at: '05:05' { send rake_method, 'oreore:import_from_ripdiko' }
every :sunday, at: '05:10' { send rake_method, 'oreore:podcast' }
