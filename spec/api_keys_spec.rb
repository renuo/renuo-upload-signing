require File.dirname(__FILE__) + '/../models/api_keys.rb'
require File.dirname(__FILE__) + '/../models/api_key.rb'

RSpec.describe 'ApiKeys', type: :model do
  context 'create api_keys array from env vars' do

    let!(:api_keys) { ApiKeys.new('{"key":"12345678","app_name":"foobar","environment": "test"}') }

    it 'generates the api_keys array from a string when initializing the model' do
      test_key = ApiKey.new('12345678', 'foobar', 'test')

      expect(api_keys.api_keys.first.key).to eq(test_key.key)
      expect(api_keys.api_keys.first.app_name).to eq(test_key.app_name)
      expect(api_keys.api_keys.first.environment).to eq(test_key.environment)
    end

    it 'check method should return false when inputting an unknown key' do
      expect(api_keys.check('87654321')).to be_falsey
    end

    it 'check method should return false when inputting an unknown key' do
      expect(api_keys.check('12345678')).to be_truthy
    end

  end
end