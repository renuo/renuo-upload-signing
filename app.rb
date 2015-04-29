require 'bundler'
require 'sinatra'
require 'dotenv'
require 'json'
require File.dirname(__FILE__) + '/models/upload_policy.rb'
require File.dirname(__FILE__) + '/models/api_keys.rb'
Bundler.require
Dotenv.load('config/.env')

configure do
  set :api_keys, ApiKeys.new(ENV['API_KEYS'])
end

post '/generate_policy' do
  response.headers['Access-Control-Allow-Origin'] = '*' #todo check if better solution exists
  content_type :json
  api_key = settings.api_keys.check(params[:api_key])
  if api_key
    upload_policy = UploadPolicy.new(api_key.app_name)
    status 200
    body "#{upload_policy.form_data.to_json}"
  else
    status 403
    body 'Invalid API key...'
  end
end
