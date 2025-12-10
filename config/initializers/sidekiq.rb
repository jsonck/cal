redis_config = {
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
}

# For Heroku Redis with TLS, disable SSL verification
if ENV['REDIS_URL']&.start_with?('rediss://')
  redis_config[:ssl_params] = { verify_mode: OpenSSL::SSL::VERIFY_NONE }
end

Sidekiq.configure_server do |config|
  config.redis = redis_config

  # Load the schedule from sidekiq.yml
  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(File.expand_path('../../sidekiq.yml', __FILE__))
    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
