class ApiKey
  attr_reader :key, :app_name, :environment

  def initialize(key, app_name, environment)
    @key = key
    @app_name = app_name
    @environment = environment
  end

  def full_app_name
    "#{@app_name}-#{@environment}"
  end
end
