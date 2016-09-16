require_relative '../spec_helper'

RSpec.describe MojFile::Add do
  let(:params) {
    {
      file_title: 'Test Upload',
      file_filename: 'testfile.docx',
      file_data: Base64.encode64('Encoded document body')
    }
  }

  around do |example|
    original_bucket = ENV['BUCKET_NAME']
    ENV['BUCKET_NAME'] = 'uploader-test-bucket'
    example.run
    ENV['BUCKET_NAME'] = original_bucket
  end

  before do
    allow(SecureRandom).to receive(:uuid).and_return(12345)
  end

  let!(:s3_stub) {
    stub_request(:put, /uploader-test-bucket.+s3.+amazonaws\.com\/12345\/testfile.docx/).
      with(body: "RW5jb2RlZCBkb2N1bWVudCBib2R5\n")
  }

  context 'successfully adding a file' do
    context 'generating a new collection_reference' do
      it 'uploads the file to s3' do
        post '/new', params.to_json
        expect(s3_stub).to have_been_requested
      end

      it 'returns a 200' do
        post '/new', params.to_json
        expect(last_response.status).to eq(200)
      end

      describe 'json response body' do

        it 'contains the file key' do
          post '/new', params.to_json
          expect(last_response.body).to match(/\"key\":\"12345.Test Upload.docx\"/)
        end

        it 'contains the collection reference' do
          post '/new', params.to_json
          expect(last_response.body).to match(/\"collection\":12345/)
        end
      end
    end

    context 'reusing a collection_reference' do
      before do
        stub_request(:put, /uploader-test-bucket.+s3.+amazonaws\.com\/ABC123\/testfile.docx/)
      end

      it 'returns a 200' do
        post '/ABC123/new', params.to_json
        expect(last_response.status).to eq(200)
      end

      describe 'json response body' do
        it 'contains the collection reference' do
          post '/ABC123/new', params.to_json
          expect(last_response.body).to match(/\"collection\":\"ABC123"/)
        end
      end
    end
  end

  context 'missing data' do
    it 'returns a 422 if the title is missing' do
      params.delete(:file_title)
      post '/new', params.to_json
      expect(last_response.status).to eq(422)
    end

    it 'returns a 422 if the filename is missing' do
      params.delete(:file_filename)
      post '/new', params.to_json
      expect(last_response.status).to eq(422)
    end

    it 'returns a 422 if the file data is missing' do
      params.delete(:file_data)
      post '/new', params.to_json
      expect(last_response.status).to eq(422)
    end

    describe 'json response body' do
      it 'explains the title is missing' do
        params.delete(:file_title)
        post '/new', params.to_json
        expect(last_response.body).to match(/\"errors\":\[\"file_title must be provided\"\]/)
      end

      it 'explains the filename is missing' do
        params.delete(:file_filename)
        post '/new', params.to_json
        expect(last_response.body).to match(/\"errors\":\[\"file_filename must be provided\"\]/)
      end

      it 'explains the file data is missing' do
        params.delete(:file_data)
        post '/new', params.to_json
        expect(last_response.body).to match(/\"errors\":\[\"file_data must be provided\"\]/)
      end
    end
  end

  context 'file_data is not base64 encoded' do
    before do
        params.merge!(file_data: 'some junk that is not base64 encoded')
    end

    it 'explains the file data is incorrectly encoded' do
      post '/new', params.to_json
      expect(last_response.body).to match(/\"errors\":\[\"file_data must be base64 encoded\"\]/)
    end
  end
end
