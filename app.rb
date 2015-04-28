require 'bundler'
Bundler.require
require 'sinatra'
require 'dotenv'
Dotenv.load('config/.env')
require 'json'
require File.dirname(__FILE__) + '/models/upload_policy.rb'

post '/upload_policy' do
  content_type :json
  upload_policy = UploadPolicy.new(params[:api_key])
  upload_policy.form_data.to_json
end
