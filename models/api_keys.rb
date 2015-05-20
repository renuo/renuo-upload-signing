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

  def check(key)
    api_keys.each do |api_key|
      if api_key.key.eql? key
        return api_key
      end
    end
    false
  end

  def validate_api_key_hash(api_key_hash)
    ! api_key_hash['key'].nil? && ! api_key_hash['app_name'].nil? && ! api_key_hash['environment'].nil?
  end
end
