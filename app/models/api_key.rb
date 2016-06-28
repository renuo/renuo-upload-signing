class ApiKey
  attr_reader :key, :private_key, :app_name, :env

  def initialize(key, private_key, app_name, env)
    @key = key
    @private_key = private_key
    @app_name = app_name
    @env = env
  end

  def full_app_name
    "#{@app_name}-#{@env}"
  end
end
