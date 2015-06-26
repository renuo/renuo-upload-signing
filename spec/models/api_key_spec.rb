require_relative '../../app/renuo_upload_signing'
require_relative '../factories/api_key'

RSpec.describe 'ApiKey', type: :model do
  context 'functionality' do
    let(:api_key) { FactoryGirl.build(:api_key) }

    it 'can be initialized' do
      expect(api_key).to be_truthy
    end

    it 'can create the full app name' do
      expect(api_key.full_app_name).to eq("#{api_key.app_name}-#{api_key.environment}")
    end
  end
end
