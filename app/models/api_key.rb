class ApiKey
  attr_reader :key, :app_name, :env

  def initialize(key, app_name, env)
    @key = key
    @app_name = app_name
    @environment = env
  end

  def full_app_name
    "#{@app_name}-#{env}"
  end
end
