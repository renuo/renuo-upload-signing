require_relative '../../app/renuo_upload_signing'
require 'rack/test'

def app
  RenuoUploadSigning
end

RSpec.describe 'RenuoUploadSigning' do
  include Rack::Test::Methods

  context 'performs every request' do
    it 'checks that an ok status is returned when posting a know api key to /generate_policy' do
      post '/generate_policy', api_key: '12345678'
      expect(last_response.status).to eq(200)
    end

    it 'checks that a 403 status is returned when posting an unknown api key to /generate_policy' do
      post '/generate_policy', api_key: 'foobar'
      expect(last_response.status).to eq(403)
    end

    it 'checks if the app can get pinged' do
      get '/ping'
      expect(last_response.body).to eq('up')
    end
  end
end
