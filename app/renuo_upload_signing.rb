require 'bundler'
require 'sinatra'
require 'dotenv'
require 'json'
require_relative 'models/api_key'
require_relative 'models/api_keys'
require_relative 'models/upload_policy'
require_relative 'services/s3_service'
require_relative 'services/authentication_service'
Bundler.require
Dotenv.load('config/.env')

# :reek:DuplicateMethodCall
class RenuoUploadSigning < Sinatra::Base
  configure do
    set :s3_service, S3Service.new
    set :authentication, AuthenticationService.new(ApiKeys.new(ENV['API_KEYS']))
  end

  post '/generate_policy' do
    set_response_headers
    api_key = settings.authentication.api_key_or_nil(params[:api_key])
    if api_key
      status 200
      body UploadPolicy.new(api_key).form_data.to_json.to_s
    else
      invalid_request
    end
  end

  get '/list_files' do
    set_response_headers
    api_key = settings.authentication.api_key_or_nil(params[:api_key])
    if api_key
      status 200
      body settings.s3_service.list_files(api_key.full_app_name).to_json.to_s
    else
      invalid_request
    end
  end

  get '/ping' do
    body 'up'
  end

  delete '/delete_file' do
    set_response_headers
    api_key = settings.authentication.api_key_or_nil(params[:api_key])
    if settings.authentication.private_api_key_valid?(api_key, params[:private_api_key])
      status 200
      #  since there is no way to find out, if successful, the deletion runs silent.
      settings.s3_service.delete_file(api_key.full_app_name, params[:file_path])
    else
      invalid_request
    end
  end

  private

  def set_response_headers
    content_type :json
    response.headers['Access-Control-Allow-Origin'] = request.env['HTTP_ORIGIN'] ? request.env['HTTP_ORIGIN'] : '*'
  end

  def invalid_request
    status 403
    body 'Invalid request.'
  end
end
