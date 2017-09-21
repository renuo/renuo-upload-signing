require_relative 'renuo_upload_signing_dependencies'

# :reek:DuplicateMethodCall
class RenuoUploadSigning < Sinatra::Base
  configure do
    set :s3_service, S3Service.new
    set :authentication, AuthenticationService.new(ApiKeys.new(ENV['API_KEYS']))
  end

  post '/generate_policy' do
    response_wrapper(api_key, 200) do
      body UploadPolicy.new(api_key).form_data.to_json.to_s
    end
  end

  get '/list_files' do
    response_wrapper(private_key_valid?, 200) do
      body settings.s3_service.list_files(api_key.full_app_name).to_json.to_s
    end
  end

  get '/ping' do
    body 'up'
  end

  delete '/delete_file' do
    response_wrapper(private_key_valid?, 204) do
      #  since there is no way to find out, if successful, the deletion runs silent.
      settings.s3_service.delete_file(api_key.full_app_name, params[:file_path])
    end
  end

  private

  def private_key_valid?
    @private_key_valid ||= settings.authentication.private_api_key_valid?(api_key, params[:private_api_key])
  end

  def api_key
    @api_key ||= settings.authentication.api_key_or_nil(params[:api_key])
  end

  # :reek:ControlParameter
  def response_wrapper(has_access, status_code)
    set_response_headers
    if has_access
      status status_code
      yield
    else
      invalid_request
    end
  end

  def set_response_headers
    content_type :json
    response.headers['Access-Control-Allow-Origin'] = request.env['HTTP_ORIGIN'] ? request.env['HTTP_ORIGIN'] : '*'
  end

  def invalid_request
    status 403
    body 'Invalid request.'
  end
end
