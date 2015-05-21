require 'raven'
require 'dotenv'
Dotenv.load('config/.env')

Raven.configure do |config|
  config.environments = %w[ production ]
  config.dsn = ENV['SENTRY_DSN']
end
