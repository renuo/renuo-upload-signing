require_relative '../../app/renuo_upload_signing'
require_relative '../factories/api_keys'

RSpec.describe 'ApiKeys', type: :model do
  let!(:api_keys) { FactoryGirl.build(:api_keys, number: 1) }

  describe '#initialize' do
    it 'tests the ApiKeys initializer with empty input' do
      api_keys1 = ApiKeys.new('')
      expect(api_keys1.api_keys.empty?).to be_truthy
    end

    it 'tests the ApiKeys initializer with faulty input' do
      api_keys2 = ApiKeys.new('{"key":"12345678", "private_key":"987654","wrong_attr":"foobar","env": "test"}')
      expect(api_keys2.api_keys.empty?).to be_truthy
    end

    it 'tests the ApiKeys initializer with multiple input' do
      api_keys3 = ApiKeys.new('{"key":"12345678", "private_key":"987654","app_name":"foobar","env": "test"};' \
        '{"key":"87654321","private_key":"987654","app_name":"raboof","env": "tset"}')
      expect(api_keys3.api_keys.count).to eq(2)
    end
  end

  describe '#find_api_key' do
    it 'returns nil if no api keys are set' do
      api_keys = FactoryGirl.build(:api_keys, api_keys: nil)
      expect(api_keys.find_api_key('some')).to be_nil
      expect(api_keys.find_api_key(nil)).to be_nil
      api_keys = FactoryGirl.build(:api_keys, api_keys: [])
      expect(api_keys.find_api_key('some')).to be_nil
    end

    it 'sees if the find_api_key method return nil if an unknown key is posted' do
      expect(api_keys.find_api_key('')).to be_falsey
    end

    it 'sees if the the find_api_key method returns the api_key if a known key is posted' do
      expect(api_keys.find_api_key(api_keys.api_keys.first.key)).to be_truthy
      expect(api_keys.find_api_key(api_keys.api_keys.first.key).class).to be(ApiKey)
    end
  end
end
