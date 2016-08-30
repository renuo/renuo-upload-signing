if ENV['SENTRY_DSN']
  require 'raven'

  Raven.configure do |config|
    config.environments = %w(production)
    config.dsn = ENV['SENTRY_DSN']
  end

  use Raven::Rack
end
