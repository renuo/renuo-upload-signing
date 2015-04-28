require 'bundler'
require 'sinatra'
require 'dotenv'
require 'json'
require File.dirname(__FILE__) + '/models/upload_policy.rb'
Bundler.require
Dotenv.load('config/.env')

post '/upload_policy' do
  content_type :json
  upload_policy = UploadPolicy.new(params[:api_key])
  upload_policy.form_data.to_json
end
