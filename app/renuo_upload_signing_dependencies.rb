require 'bundler'
require 'sinatra'
require 'json'
require 'dotenv'

Dotenv.load('config/.env')

require_relative '../config/initializers/new_relic'
require_relative '../config/initializers/raven'

require_relative 'models/api_key'
require_relative 'models/api_keys'
require_relative 'models/upload_policy'

require_relative 'services/s3_service'
require_relative 'services/authentication_service'

Bundler.require
