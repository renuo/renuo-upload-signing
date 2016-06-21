require 'aws-sdk'
require 'dotenv'
Dotenv.load('config/.env')

# :reek:DuplicateMethodCall
# :reek:UtilityFunction
# :reek:UncommunicativeVariableName
# :reek:FeatureEnvy
class S3Service
  def initialize(s3_secret = ENV['S3_SECRET_KEY'], s3_key = ENV['S3_PUBLIC_KEY'])
    Aws.config.update(region: 'eu-central-1', credentials: Aws::Credentials.new(s3_key, s3_secret))
  end

  def list_files(app_name, bucket = ENV['S3_BUCKET_NAME'])
    s3 = Aws::S3::Client.new
    s3.list_objects(bucket: bucket, prefix: "o/#{app_name}").map { |response| parse_response(response) }.flatten
  end

  private

  def parse_response(response)
    response.contents.map do |struct_s3|
      filename = parse_filename(struct_s3.key)
      {
        name: filename[0],
        filetype: filename[1],
        url: struct_s3.key,
        created_at: struct_s3.last_modified,
        size: struct_s3.size
      }
    end
  end

  def parse_filename(key)
    key.split('/').last.split('.')
  end
end
