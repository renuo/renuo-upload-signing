require 'factory_girl'
require 'faker'
require_relative 'aws_s3_types_objects'

class AwsS3TypesListObjectsOutput
  attr_accessor :contents
end

FactoryGirl.define do
  factory :aws_s3_types_list_objects_output do
    after(:build) do |aws_s3_types_list_objects_output|
      aws_s3_types_list_objects_output.contents = FactoryGirl.build_list(:aws_s3_types_object, 5)
    end
  end
end
