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

job_type :rbenv_rake, %q!PATH="$HOME/.rbenv/bin:$PATH"; eval "$(rbenv init -)"; cd :path && :bundle_command rake :task --silent :output!
job_type :be_rake, 'cd :path && :bundle_command rake :task --silent :output'

def rake_method
  File.exist?("#{ENV['HOME']}/.rbenv/bin") ? :rbenv_rake : :be_rake
end

# junk
every '10 3 * * 0,2-6' do
  send rake_method, 'oreore:podcast'
end

# paka
every :saturday, at: '17:00' do
  send rake_method, 'oreore:podcast'
end

# tama954
every '40 15 * * 1-5' do
  send rake_method, 'oreore:podcast'
end

# nichiten
every :sunday, at: '12:05' do
  send rake_method, 'oreore:podcast'
end
