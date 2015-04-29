require 'base64'
require 'securerandom'
require 'openssl'
require 'json'
require 'bcrypt'

class UploadPolicy
  attr_reader :form_data

  def initialize(app_name, s3_bucket = ENV['S3_BUCKET_NAME'], s3_secret = ENV['S3_SECRET_KEY'],
                 s3_key = ENV['S3_PUBLIC_KEY'])

    algorithm = 'AWS4-HMAC-SHA256'
    expires = 8 * 3600
    @date = Time.now.getutc
    @expiration = @date + expires
    request_type = 'aws4_request'
    service = 's3'
    s3_region = 'eu-central-1'
    s3_acl = 'public-read'

    check_params(app_name, s3_bucket, s3_secret, s3_key)

    file_key_base = create_file_key_base(app_name)

    key = create_file_key(file_key_base)

    credential = create_credential(s3_key, short_date, s3_region, service, request_type)

    policy = create_policy(expiration_date, s3_bucket, s3_acl, file_key_base, credential, algorithm,
                           long_date, expires)

    signing_key = create_signing_key(s3_secret, s3_region, service, short_date)

    signature = create_signature(signing_key, policy)

    url = create_url(s3_bucket, service, s3_region)

    @form_data = create_form_data(url, key, s3_acl, policy, algorithm, credential, expires,
                                  signature, long_date)
  end

  private

  def short_date
    @date.strftime('%Y%m%d')
  end

  def long_date
    @date.strftime('%Y%m%dT%H%M%SZ')
  end

  def expiration_date
    @expiration.strftime('%Y-%m-%dT%H:%M:%SZ')
  end

  def create_credential(key, short_date, region, service, request_type)
    [key, short_date, region, service, request_type].join('/')
  end

  def create_policy(expiration, bucket, acl, file_key_base, credential, algorithm, long_date, expires)
    policy = {
        expiration: expiration,
        conditions: [
            {bucket: bucket},
            {acl: acl},
            ['starts-with', '$key', file_key_base],
            ['starts-with', '$utf8', '✓'],
            {:'x-amz-credential' => credential},
            {:'x-amz-algorithm' => algorithm},
            {:'x-amz-date' => long_date},
            {:'x-amz-expires' => expires.to_s}
        ]
    }
    Base64.encode64(JSON.dump(policy)).gsub("\n", '')
  end

  def create_signature(signing_key, policy)
    OpenSSL::HMAC.hexdigest('sha256', signing_key, policy)
  end

  def create_url(bucket, service, region)
    "http://#{bucket}.#{service}.#{region}.amazonaws.com/"
  end

  def create_signing_key(secret, region, service, short_date)
    k_date = OpenSSL::HMAC.digest('sha256', "AWS4" + secret, short_date)
    k_region = OpenSSL::HMAC.digest('sha256', k_date, region)
    k_service = OpenSSL::HMAC.digest('sha256', k_region, service)
    k_signing = OpenSSL::HMAC.digest('sha256', k_service, 'aws4_request')
  end

  def create_file_key_base(app_name)

    prefix = SecureRandom.hex(16).gsub(/(.{4})/, '\1/')
    ['o/', app_name, '/', prefix].join
  end

  def create_file_key(file_key_base)
    "#{file_key_base}${filename}"
  end

  def create_form_data(url, key, s3_acl, policy, algorithm, credential, expires, signature, date)
    {
        url: url,
        data: {
            key: key,
            acl: s3_acl,
            policy: policy,
            x_amz_algorithm: algorithm,
            x_amz_credential: credential,
            x_amz_expires: expires,
            x_amz_signature: signature,
            x_amz_date: date,
            utf8: '✓'
        }
    }
  end

  def blank?(string)
    return true if string == '' || string.nil?
  end

  def check_params(app_name, s3_bucket, s3_secret, s3_key)
    raise "App_name is not defined!" if blank?(app_name)
    raise "S3 bucket name is not defined! Set it over ENV['S3_BUCKET_NAME']." if blank?(s3_bucket)
    raise "S3 public key is not defined! Set it over ENV['S3_PUBLIC_KEY']." if blank?(s3_secret)
    raise "S3 secret key is not defined! Set it over ENV['S3_SECRET_KEY']." if blank?(s3_key)
  end
end
