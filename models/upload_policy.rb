require 'base64'
require 'securerandom'
require 'openssl'
require 'json'
require 'digest'

class UploadPolicy
  attr_reader :form_data

  def initialize(api_key, s3_bucket = ENV['S3_BUCKET_NAME'], s3_secret = ENV['S3_SECRET_KEY'],
                 s3_key = ENV['S3_PUBLIC_KEY'], cdn_host = ENV['CDN_HOST'])

    algorithm = 'AWS4-HMAC-SHA256'
    expires = 8 * 3600
    @date = Time.now.getutc
    @expiration = @date + expires
    request_type = 'aws4_request'
    service = 's3'
    s3_region = 'eu-central-1'
    s3_acl = 'public-read'

    check_params(api_key, s3_bucket, s3_secret, s3_key, cdn_host)

    file_prefix = create_file_prefix(api_key)

    file_key_base = create_file_key_base(api_key, file_prefix)

    file_url_path = create_file_url_path(cdn_host, file_key_base)

    key = create_file_key(file_key_base)

    credential = create_credential(s3_key, short_date, s3_region, service, request_type)

    policy = create_policy(expiration_date, s3_bucket, s3_acl, file_key_base, credential, algorithm,
                           long_date, expires)

    signing_key = create_signing_key(s3_secret, s3_region, service, short_date)

    signature = create_signature(signing_key, policy)

    url = create_url(s3_bucket, service, s3_region)

    @form_data = create_form_data(url, key, s3_acl, policy, algorithm, credential, expires,
                                  signature, long_date, file_prefix, file_url_path)
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
    "https://#{bucket}.#{service}.#{region}.amazonaws.com/"
  end

  def create_signing_key(secret, region, service, short_date)
    k_date = OpenSSL::HMAC.digest('sha256', "AWS4" + secret, short_date)
    k_region = OpenSSL::HMAC.digest('sha256', k_date, region)
    k_service = OpenSSL::HMAC.digest('sha256', k_region, service)
    OpenSSL::HMAC.digest('sha256', k_service, 'aws4_request')
  end

  def createIdentifier(secret_key, api_key, month, year)
    arr = [secret_key, api_key, month, year].map(&:to_s)
    base64hash = Digest::SHA512.base64digest(arr.join('--'))
    base64hash.downcase.gsub(/[^0-9a-z]/i, '')[0..3]
  end

  def create_file_prefix(api_key)
    today = Date.today
    identifier = createIdentifier(ENV['SECRET_KEY'], api_key.key, today.month, today.year)
    prefix = SecureRandom.hex(16).gsub(/(.{4})/, '\1/')
    [identifier, '/', prefix].join
  end

  def create_file_key_base(api_key, prefix)
    ['o/', api_key.app_name, '/', prefix].join
  end

  def create_file_key(file_key_base)
    "#{file_key_base}${filename}"
  end

  def create_file_url_path(cdn_host, file_key_base)
    ['//', cdn_host, '/', file_key_base].join
  end

  def create_form_data(url, key, s3_acl, policy, algorithm, credential, expires, signature, date, file_prefix,
                       file_url_path)
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
        },
        file_prefix: file_prefix,
        file_url_path: file_url_path
    }
  end

  def blank?(string)
    return true if string == '' || string.nil?
  end

  def check_params(api_key, s3_bucket, s3_secret, s3_key, cdn_host)
    raise "Api_key is not defined!" if blank?(api_key)
    raise "S3 bucket name is not defined! Set it over ENV['S3_BUCKET_NAME']." if blank?(s3_bucket)
    raise "S3 secret key is not defined! Set it over ENV['S3_SECRET_KEY']." if blank?(s3_secret)
    raise "S3 public key is not defined! Set it over ENV['S3_PUBLIC_KEY']." if blank?(s3_key)
    raise "CDN host is not defined! Set it over ENV['CDN_HOST']." if blank?(cdn_host)
  end
end
