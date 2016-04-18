require_relative 'app/renuo_upload_signing'

require 'newrelic_rpm' if ENV['NEW_RELIC_LICENSE_KEY']

if ENV['SENTRY_DSN']
  require 'raven'

  Raven.configure do |config|
    config.environments = %w( production )
    config.dsn = ENV['SENTRY_DSN']
  end

  use Raven::Rack
end

run RenuoUploadSigning
