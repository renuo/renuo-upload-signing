require_relative '../../app/models/api_key'
require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :api_key do
    key { Faker::Internet.password(8) }
    app_name { Faker::Internet.user_name }
    environment { %w(master develop testing).sample }
    initialize_with { new(key, app_name, environment) }
  end
end
