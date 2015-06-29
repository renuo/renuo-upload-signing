source 'https://rubygems.org'

ruby File.read('.ruby-version').strip

gem 'sinatra', require: 'sinatra/base'
gem 'puma'
gem 'json'
gem 'dotenv'
gem 'aws-sdk'

group :development do
  gem 'rubocop'
end

group :test do
  gem 'rspec'
  gem 'rack-test', require: 'rack/test'
  gem 'faker'
  gem 'factory_girl'
end

group :production do
  gem 'newrelic_rpm'
  gem 'sentry-raven'
end
