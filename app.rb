require 'bundler'
require 'sinatra'
require 'dotenv'
require 'json'
require 'raven'
require File.dirname(__FILE__) + '/models/upload_policy.rb'
require File.dirname(__FILE__) + '/models/api_keys.rb'
Bundler.require
Dotenv.load('config/.env')

configure do
  Raven.configure do |config|
    config.environments = %w[ production ]
    config.dsn = ENV['SENTRY_DSN']
  end

  set :api_keys, ApiKeys.new(ENV['API_KEYS'])
end

post '/generate_policy' do
  Raven.capture do
    response.headers['Access-Control-Allow-Origin'] = '*' # TODO: check if better solution exists
    content_type :json
    api_key = settings.api_keys.find_api_key(params[:api_key])
    if api_key
      upload_policy = UploadPolicy.new(api_key)
      status 200
      body "#{upload_policy.form_data.to_json}"
    else
      status 403
      body 'Invalid API key...'
    end
    1 / 0
  end
end

get '/ping' do
  body 'up'
end
