require 'sidekiq'
require 'sidekiq-cron'

schedule_file = 'config/sidekiq.yml'

if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)[:cron]
end
