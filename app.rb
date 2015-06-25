require 'bundler'
require 'sinatra'
require 'dotenv'
require 'json'
require_relative 'models/upload_policy.rb'
require_relative 'models/api_keys.rb'
Bundler.require
Dotenv.load('config/.env')

configure do
  set :api_keys, ApiKeys.new(ENV['API_KEYS'])
end

post '/generate_policy' do
  response.headers['Access-Control-Allow-Origin'] = request.env['HTTP_ORIGIN'] ? request.env['HTTP_ORIGIN'] : '*'
  content_type :json
  api_key = settings.api_keys.find_api_key(params[:api_key])
  if api_key
    upload_policy = UploadPolicy.new(api_key)
    status 200
    body "#{upload_policy.form_data.to_json}"
  else
    status 403
    body 'Invalid API key.'
  end
end

get '/ping' do
  body 'up'
end
