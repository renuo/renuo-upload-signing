require 'bundler'
require 'sinatra'
require 'dotenv'
require 'json'
require_relative 'models/api_key'
require_relative 'models/api_keys'
require_relative 'models/upload_policy'
require_relative 'services/s3_service'
Bundler.require
Dotenv.load('config/.env')

class RenuoUploadSigning < Sinatra::Base
  configure do
    set :api_keys, ApiKeys.new(ENV['API_KEYS'])
    set :s3_service, S3Service.new
  end

  post '/generate_policy' do
    set_response_headers
    content_type :json
    api_key = settings.api_keys.find_api_key(params[:api_key])
    if api_key
      status 200
      body "#{UploadPolicy.new(api_key).form_data.to_json}"
    else
      invalid_request
    end
  end

  get '/list_files' do
    set_response_headers
    content_type :json
    api_key = settings.api_keys.find_api_key(params[:api_key])
    if api_key
      status 200
      body "#{settings.s3_service.list_files(api_key.full_app_name).to_json}"
    else
      invalid_request
    end
  end

  get '/ping' do
    body 'up'
  end

  private

  def set_response_headers
    response.headers['Access-Control-Allow-Origin'] = request.env['HTTP_ORIGIN'] ? request.env['HTTP_ORIGIN'] : '*'
  end

  def invalid_request
    status 403
    body 'Invalid API key.'
  end
end

