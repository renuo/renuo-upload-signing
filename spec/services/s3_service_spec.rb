require_relative '../../app/services/s3_service'
require_relative '../factories/aws_s3_types_list_objects_outputs'

RSpec.describe 'List files of bucket', type: :feature do
  context 'S3Service' do
    let(:list_objects_output) { FactoryGirl.build(:aws_s3_types_list_objects_output) }
    let(:s3_service) { S3Service.new }

    def check_object(id)
      expect(s3_service.list_files[id][:url]).to eq(list_objects_output.contents[id].key)
      expect(s3_service.list_files[id][:created_at]).to eq(list_objects_output.contents[id].last_modified)
      expect(s3_service.list_files[id][:size]).to eq(list_objects_output.contents[id].size)
      expect(s3_service.list_files[id][:name]).to be_truthy
      expect(s3_service.list_files[id][:filetype]).to be_truthy
    end

    it 'should list all buckets' do
      allow_any_instance_of(Aws::S3::Client).to receive(:list_objects).and_return([list_objects_output])

      check_object(0)
      check_object(4)
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
  end
end
