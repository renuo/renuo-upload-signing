require_relative '../../app/models/api_key'
require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :api_key do
    key { Faker::Internet.password(8) }
    private_key { Faker::Internet.password(8) }
    app_name { Faker::Internet.user_name }
    env { %w(master develop testing).sample }
    initialize_with { new(key, private_key, app_name, env) }
  end
end
