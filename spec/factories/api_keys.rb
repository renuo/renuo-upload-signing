require_relative '../../app/models/api_keys'
require_relative 'api_key'
require 'factory_girl'
require 'faker'

FactoryGirl.define do
  factory :api_keys do
    transient do
      number 5
      api_keys { FactoryGirl.build_list(:api_key, number) }
    end

    initialize_with { new('') }

    after(:build) do |api_keys, evaluator|
      api_keys.instance_variable_set(:@api_keys, evaluator.api_keys)
    end
  end
end
