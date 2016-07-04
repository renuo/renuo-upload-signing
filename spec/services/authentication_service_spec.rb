require_relative '../../app/services/authentication_service'
require_relative '../factories/api_keys'

RSpec.describe AuthenticationService, type: :feature do
  describe '#initalize' do
    it 'contains api_keys' do
      api_keys = FactoryGirl.build(:api_keys, number: 2)
      keys = AuthenticationService.new(api_keys).instance_variable_get(:@api_keys)
      expect(keys).to eq(api_keys)
      expect(keys).to be_a ApiKeys
    end
  end
  describe '#private_api_key_valid?' do
    let(:auth) { AuthenticationService.new(nil) }
    it 'validates the private_key to the given api_key' do
      api_key = FactoryGirl.build(:api_key, key: 'validKey', private_key: 'private')
      expect(auth.private_api_key_valid?(api_key, 'invalidPrivate')).to be_falsey
      expect(auth.private_api_key_valid?(api_key, 'private')).to be_truthy
    end
  end
end
