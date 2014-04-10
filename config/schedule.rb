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

env :PATH, ENV['PATH']

set :output, nil

job_type :rake, "cd :path && :bundle_command rake :task --silent :output"

# junk
every '10 3 * * 0-6' do
  rake 'oreore:podcast'
end

# paka
every :saturday, at: '17:00' do
  rake 'oreore:podcast'
end

# tama954
every '40 15 * * 1-5' do
  rake 'oreore:podcast'
end

# nichiten
every :sunday, at: '12:05' do
  rake 'oreore:podcast'
end
