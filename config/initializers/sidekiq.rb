# config/initializers/sidekiq.rb
require 'sidekiq'
require 'sidekiq-cron'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6380/0') }
  
  # Recurring Jobs definieren
  Sidekiq::Cron::Job.load_from_hash({
    'api_polling' => {
      'cron' => '* * * * *',  # Jede Minute
      'class' => 'ApiPollerJob'
    }
  })
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6380/0') }
end