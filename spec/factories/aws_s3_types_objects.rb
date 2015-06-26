require 'factory_girl'
require 'faker'

class AwsS3TypesObject
  attr_accessor :key, :last_modified, :size
end

FactoryGirl.define do
  factory :aws_s3_types_object do
    key {Faker::Avatar.image}
    last_modified {Faker::Time.backward(30)}
    size {Faker::Number.number(5)}
  end
end
