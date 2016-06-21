require_relative '../../app/renuo_upload_signing'
require_relative '../factories/aws_s3_types_list_objects_outputs'
require_relative '../factories/api_keys'

require 'rack/test'

RSpec.describe 'RenuoUploadSigning' do
  include Rack::Test::Methods

  let(:app) { RenuoUploadSigning }
  let(:api_keys) { FactoryGirl.build(:api_keys, number: 1) }

  before do
    RenuoUploadSigning.set :api_keys, api_keys
  end

  context 'performs every request' do
    it 'checks if the response is valid when posting a know api key to /generate_policy' do
      post '/generate_policy', api_key: api_keys.api_keys.first.key
      expect(last_response.status).to eq(200)
      expect { JSON.parse(last_response.body) }.to_not raise_error
    end

    it 'checks that a 403 status is returned when posting an unknown api key to /generate_policy' do
      post '/generate_policy', api_key: 'foobar'
      expect(last_response.status).to eq(403)
      expect(last_response.body).to eq('Invalid API key.')
    end

    it 'checks if the response is valid when getting a know api key to /list_files' do
      allow_any_instance_of(Aws::S3::Client).to receive(:list_objects)
        .and_return([FactoryGirl.build(:aws_s3_types_list_objects_output)])

      get '/list_files', api_key: api_keys.api_keys.first.key
      expect(last_response.status).to eq(200)
      expect { JSON.parse(last_response.body) }.to_not raise_error
    end

    it 'checks if the app can get pinged' do
      get '/ping'
      expect(last_response.body).to eq('up')
    end
  end
end
