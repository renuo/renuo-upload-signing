require File.dirname(__FILE__) + '/../models/upload_policy.rb'

RSpec.describe 'CORS s3 upload', type: :feature do

  context 'server side part of CORS upload' do

    let!(:upload_policy) { UploadPolicy.new('a', 'a', 'a', 'a') }

    it 'should return valid credentials' do
      key = 'AKIAJ6Y6YEIY7JNZFGMA'
      short_date = '20150326'
      region = 'eu-central-1'
      service = 's3'
      request_type = 'aws4_request'
      credential = 'AKIAJ6Y6YEIY7JNZFGMA/20150326/eu-central-1/s3/aws4_request'

      generated_credential = upload_policy.send(:create_credential, key, short_date, region, service, request_type)

      expect(generated_credential).to eq(credential)
    end

    it 'should return a valid policy' do
      expiration = '2015-04-14T15:31:32Z'
      bucket = 'schuler-cyrilkyburz-develop'
      acl = 'public-read'
      file_key_base = 'a/a31babfc9fdffa6631ec25a9f767468/'
      credential = 'AKIAJWCFLKAZMV375XUA/20150414/eu-central-1/s3/aws4_request'
      algorithm = 'AWS4-HMAC-SHA256'
      long_date = '20150414T073132Z'
      expires = 28800
      policy = 'eyJleHBpcmF0aW9uIjoiMjAxNS0wNC0xNFQxNTozMTozMloiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJzY2h1bGVyLWN5cmls'\
               'a3lidXJ6LWRldmVsb3AifSx7ImFjbCI6InB1YmxpYy1yZWFkIn0sWyJzdGFydHMtd2l0aCIsIiRrZXkiLCJhL2EzMWJhYmZjOWZk'\
               'ZmZhNjYzMWVjMjVhOWY3Njc0NjgvIl0sWyJzdGFydHMtd2l0aCIsIiR1dGY4Iiwi4pyTIl0seyJ4LWFtei1jcmVkZW50aWFsIjoi'\
               'QUtJQUpXQ0ZMS0FaTVYzNzVYVUEvMjAxNTA0MTQvZXUtY2VudHJhbC0xL3MzL2F3czRfcmVxdWVzdCJ9LHsieC1hbXotYWxnb3Jp'\
               'dGhtIjoiQVdTNC1ITUFDLVNIQTI1NiJ9LHsieC1hbXotZGF0ZSI6IjIwMTUwNDE0VDA3MzEzMloifSx7IngtYW16LWV4cGlyZXMi'\
               'OiIyODgwMCJ9XX0='

      generated_policy = upload_policy.send(:create_policy, expiration, bucket, acl, file_key_base,
                                            credential, algorithm, long_date, expires)

      expect(generated_policy).to eq(policy)
    end

    it 'should return a valid signing key' do
      secret = 'vqFoo7Or7mUUDMy3kL8z+ughsQ2cGB1Vz2eSMBPO'
      region = 'eu-central-1'
      service = 's3'
      short_date = '20150326'
      signing_key = Base64.decode64('6l+VGIvb0VcI5cUuyl2sLnhNWEyAwITEeUzTYqlqelc=')
      generated_signing_key = upload_policy.send(:create_signing_key, secret, region, service, short_date)

      expect(generated_signing_key).to eq(signing_key)
    end

    it 'should return a valid signature' do
      signature = '0d3a97339be1c1fa1e9cff33c3f7c608c7713a3f9cdcd6193f738a18eeac442e'
      signing_key = Base64.decode64('6l+VGIvb0VcI5cUuyl2sLnhNWEyAwITEeUzTYqlqelc=')
      policy = 'eyJleHBpcmF0aW9uIjoiMjAxNS0wMy0yNlQyMTo1NzowNVoiLCJjb25kaXRpb25zIjpbeyJidWNrZXQiOiJzY2h1bGVyLWN5cmlsa'\
      '3lidXJ6LWRldmVsb3AifSx7ImFjbCI6InB1YmxpYy1yZWFkIn0sWyJzdGFydHMtd2l0aCIsIiRrZXkiLCIiXSx7InN1Y2Nlc3NfYWN0aW9uX3N'\
      '0YXR1cyI6IjIwMSJ9LHsieC1hbXotY3JlZGVudGlhbCI6IkFLSUFKNlk2WUVJWTdKTlpGR01BXC8yMDE1MDMyNlwvZXUtY2VudHJhbC0xXC9zM'\
      '1wvYXdzNF9yZXF1ZXN0In0seyJ4LWFtei1hbGdvcml0aG0iOiJBV1M0LUhNQUMtU0hBMjU2In0seyJ4LWFtei1kYXRlIjoiMjAxNTAzMjZUMTU'\
      '1NzA1WiJ9LHsieC1hbXotZXhwaXJlcyI6Ijg2NDAwIn1dfQ=='

      generated_signature = upload_policy.send(:create_signature, signing_key, policy)

      expect(generated_signature).to eq(signature)
    end

    it 'should return a valid s3 url' do
      bucket = 'schuler-cyrilkyburz-develop'
      service = 's3'
      region = 'eu-central-1'
      url = 'http://schuler-cyrilkyburz-develop.s3.eu-central-1.amazonaws.com/'
      created_url = upload_policy.send(:create_url, bucket, service, region)

      expect(created_url).to eq(url)
    end


    it 'should return a valid file key base' do
      api_key1 = '123'

      file_key_base1 = upload_policy.send(:create_file_key_base, api_key1)

      expect(file_key_base1.length).to eq(35)
    end


    it 'should return a valid file key' do
      file_key_base = 'a1/db380d1863a98c2f933051d8726a1c/'
      file_key = 'a1/db380d1863a98c2f933051d8726a1c/${filename}'
      created_file_key = upload_policy.send(:create_file_key, file_key_base)

      expect(created_file_key).to eq(file_key)
    end

    it 'should return a valid form data hash' do
      url = 'a'
      key = 'b'
      s3_acl = 'd'
      policy = 'e'
      algorithm = 'f'
      credential = 'g'
      expires = 'h'
      signature = 'i'
      date = 'j'
      created_form_data = upload_policy.send(:create_form_data, url, key, s3_acl, policy, algorithm,
                                             credential, expires, signature, date)

      expect(created_form_data[:url]).to eq(url)
      expect(created_form_data[:data][:key]).to eq(key)
      expect(created_form_data[:data][:acl]).to eq(s3_acl)
      expect(created_form_data[:data][:policy]).to eq(policy)
      expect(created_form_data[:data][:x_amz_algorithm]).to eq(algorithm)
      expect(created_form_data[:data][:x_amz_credential]).to eq(credential)
      expect(created_form_data[:data][:x_amz_expires]).to eq(expires)
      expect(created_form_data[:data][:x_amz_signature]).to eq(signature)
      expect(created_form_data[:data][:x_amz_date]).to eq(date)
      expect(created_form_data[:data][:utf8]).to eq('✓')
    end

    it 'should raise an error if a necessary param is missing' do
      app_name = ''
      s3_bucket = ''
      s3_secret = ''
      s3_key = ''

      expect { upload_policy.send(:check_params, app_name, s3_bucket, s3_secret, s3_key) }.
          to raise_error(RuntimeError,
                         "Renuo upload api_key is not defined! Set it over ENV['RENUO_UPLOAD_API_KEY'].")

      app_name = 'a'

      expect { upload_policy.send(:check_params, app_name, s3_bucket, s3_secret, s3_key) }.
          to raise_error(RuntimeError,
                         "Renuo upload bucket name is not defined! Set it over ENV['RENUO_UPLOAD_BUCKET_NAME'].")

      s3_bucket = 'a'

      expect { upload_policy.send(:check_params, app_name, s3_bucket, s3_secret, s3_key) }.
          to raise_error(RuntimeError,
                         "Renuo upload public key is not defined! Set it over ENV['RENUO_UPLOAD_PUBLIC_KEY'].")

      s3_secret = 'a'

      expect { upload_policy.send(:check_params, app_name, s3_bucket, s3_secret, s3_key) }.
          to raise_error(RuntimeError,
                         "Renuo upload secret key is not defined! Set it over ENV['RENUO_UPLOAD_SECRET_KEY'].")
    end
  end
end