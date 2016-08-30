source 'https://rubygems.org'

ruby File.read('.ruby-version').strip

gem 'aws-sdk'
gem 'dotenv'
gem 'json'
gem 'newrelic_rpm'
gem 'puma'
gem 'sentry-raven'
gem 'sinatra', require: 'sinatra/base'

group :test do
  gem 'factory_girl'
  gem 'faker'
  gem 'rack-test', require: 'rack/test'
  gem 'rspec'
end

group :lint do
  gem 'reek', require: false
  gem 'rubocop', require: false
end
