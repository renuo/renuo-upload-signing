require_relative 'app'
require 'newrelic_rpm'
require 'raven'

Raven.configure do |config|
  config.environments = %w( production )
  config.dsn = ENV['SENTRY_DSN']
end

use Raven::Rack

run Sinatra::Application
