class AuthenticationService
  def initialize(api_keys)
    @api_keys = api_keys
  end

  def api_key_or_nil(api_key)
    @api_keys.find_api_key(api_key)
  end

  def private_api_key_valid?(api_key, private_key)
    api_key && api_key.private_key == private_key
  end
end
