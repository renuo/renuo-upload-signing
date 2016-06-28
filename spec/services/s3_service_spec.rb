require_relative '../../app/services/s3_service'
require_relative '../factories/aws_s3_types_list_objects_outputs'

RSpec.describe 'List files of bucket', type: :feature do
  context 'S3Service' do
    let(:list_objects_output) { FactoryGirl.build(:aws_s3_types_list_objects_output) }
    let(:s3_service) { S3Service.new }

    # rubocop:disable Metrics/AbcSize
    def check(files)
      id = Random.rand(5)
      expect(files[id][:url]).to eq(list_objects_output.contents[id].key)
      expect(files[id][:created_at]).to eq(list_objects_output.contents[id].last_modified)
      expect(files[id][:size]).to eq(list_objects_output.contents[id].size)
      expect(files[id][:name]).to be_truthy
      expect(files[id][:filetype]).to be_truthy
    end

    # rubocop:enable Metrics/AbcSize

    it 'should list all buckets' do
      bucket = Faker::Internet.domain_name
      app_name = Faker::Internet.domain_name

      allow_any_instance_of(Aws::S3::Client).to receive(:list_objects)
        .with(bucket: bucket, prefix: "o/#{app_name}")
        .and_return([list_objects_output])
      files = s3_service.list_files(app_name, bucket)

      check(files)
    end

    it 'should parse the correct data from the response' do
      files = s3_service.send(:parse_response, list_objects_output)

      check(files)
    end

    it 'should parse the correct filename from a original url' do
      filename = s3_service.send(:parse_filename, 'o/app/1212/0542/a777/8df5/0f3f/55aa/cc89/report.xls')
      expect(filename[0]).to eq('report')
      expect(filename[1]).to eq('xls')
    end

    it 'should parse the correct filename from a thumbor url' do
      filename = s3_service.send(:parse_filename, '/t/0x150/u/o/app/1212/0542/a777/8df5/537a/c367/cc89/image.png')
      expect(filename[0]).to eq('image')
      expect(filename[1]).to eq('png')
    end

    describe '#delete_file' do
      it 'uses the default bucket set by ENV if no bucket expected' do
        file_path = 'object_key'
        expect_any_instance_of(Aws::S3::Client).to receive(:delete_object).with(bucket: ENV['S3_BUCKET_NAME'],
                                                                                key: file_path)
        s3_service.delete_file(file_path)
      end

      it 'calls the AWS API with the right arguments' do
        file_path = 'object_key'
        bucket = 'testBucket'
        stubbed_delete_call = Aws::S3::Client.new(stub_responses: true).delete_object(bucket: bucket, key: file_path)
        expect_any_instance_of(Aws::S3::Client).to receive(:delete_object).with(bucket: bucket, key: file_path)
          .and_return(stubbed_delete_call)
        response = s3_service.delete_file(file_path, bucket)
        expect(response.successful?).to be_truthy
        expect(response.data).to be_a Aws::S3::Types::DeleteObjectOutput
      end
      #
      #
      # it 'calls the AWS API with the right arguments' do
      #   file_path = 'o/renuo-upload-demo-development/ddvh/04e3/d79a/1466/7525/dfae/8fae/2650/4cc5/fff-6.png'
      #   response = s3_service.delete_file(file_path)
      #   expect(response.successful?).to be_truthy
      #   expect(response.data).to be_a Aws::S3::Types::DeleteObjectOutput
      # end
    end
  end
end
