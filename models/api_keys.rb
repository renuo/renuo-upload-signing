require File.dirname(__FILE__) + '/api_key.rb'
require 'dotenv'
require 'json'
Dotenv.load('config/.env')

class ApiKeys
  attr_reader :api_keys

  def initialize(keys_string)
    keys = keys_string.split(';')
    @api_keys = []
    keys.each do |key_params|
      begin
        key_params = JSON.parse(key_params)
      rescue
        next
      end
      if validate_api_key_hash(key_params)
        @api_keys << ApiKey.new(key_params['key'], key_params['app_name'], key_params['environment'])
      end
    end
  end

  def find_api_key(key)
    @api_keys.find { |api_key| api_key.key.eql? key }
  end

  def validate_api_key_hash(api_key_hash)
    api_key_hash['key'] && api_key_hash['app_name'] && api_key_hash['environment']
  end
end
