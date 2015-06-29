require_relative '../../app/models/api_keys'
require_relative 'api_key'
require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :api_keys do
    transient do
      number 5
    end

    initialize_with { new('') }

    after(:build) do |api_keys, evaluator|
      api_keys.instance_variable_set(:@api_keys, FactoryGirl.build_list(:api_key, evaluator.number))
    end
  end
end
