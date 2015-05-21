require_relative 'app'
require 'newrelic_rpm'
require 'raven'

Raven.configure do |config|
  config.environments = %w[ production ]
  config.dsn = ENV['SENTRY_DSN']
end

Raven.capture do
  run Sinatra::Application
end
