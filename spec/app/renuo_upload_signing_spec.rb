require_relative '../../app/renuo_upload_signing'
require_relative '../factories/aws_s3_types_list_objects_outputs'
require_relative '../factories/api_keys'

require 'rack/test'

RSpec.describe RenuoUploadSigning do
  include Rack::Test::Methods

  let(:app) { RenuoUploadSigning.new! }
  let(:api_keys) { FactoryGirl.build(:api_keys, number: 1) }

  before do
    RenuoUploadSigning.set :authentication, AuthenticationService.new(api_keys)
  end

  def expect_response_headers(response)
    expect(response.headers['Access-Control-Allow-Origin']).to eq('*')
  end

  def expect_json_content_type(response)
    expect(response.header['Content-Type']).to eq('application/json')
  end

  context '/generate_policy' do
    it 'checks if the response is valid when posting a know api key to /generate_policy' do
      post '/generate_policy', api_key: api_keys.api_keys.first.key
      expect_response_headers(last_response)
      expect_json_content_type(last_response)
      expect(last_response.status).to eq(200)
      expect { JSON.parse(last_response.body) }.to_not raise_error
    end

    it 'checks that a 403 status is returned when posting an unknown api key to /generate_policy' do
      post '/generate_policy', api_key: 'foobar'
      expect_response_headers(last_response)
      expect_json_content_type(last_response)
      expect(last_response.body).to eq('Invalid request.')
    end
  end

  context '/list_files' do
    it 'checks if the response is valid when getting a know api key to /list_files' do
      allow_any_instance_of(Aws::S3::Client).to receive(:list_objects)
        .and_return([FactoryGirl.build(:aws_s3_types_list_objects_output)])

      get '/list_files', api_key: api_keys.api_keys.first.key
      expect_response_headers(last_response)
      expect_json_content_type(last_response)
      expect(last_response.status).to eq(200)
      expect { JSON.parse(last_response.body) }.to_not raise_error
    end
  end

  context '/ping' do
    it 'checks if the app can get pinged' do
      get '/ping'
      expect(last_response.body).to eq('up')
    end
  end

  context '/delete_file' do
    it 'returns a 403 if wrong api-key or wrong private key' do
      delete '/delete_file', api_key: 'foobarWrong', file_path: 'path/to/file.ext'
      expect(last_response.status).to eq(403)
      expect(last_response.body).to eq('Invalid request.')
      delete '/delete_file', api_key: 'foobar', private_key: 'invalid', file_path: 'path/to/file.ext'
      expect(last_response.status).to eq(403)
      expect(last_response.body).to eq('Invalid request.')
    end

    it 'returns statuscode 200 and deletes file' do
      file_path = '/path/to/file.ext'
      expect_any_instance_of(AuthenticationService).to receive(:private_api_key_valid?).and_return(true)
      expect_any_instance_of(S3Service).to receive(:delete_file).with(file_path).and_return(nil)
      delete '/delete_file', file_path: file_path
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq('')
    end
  end
end
