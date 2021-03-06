require 'spec_helper'

RSpec.describe MojFile::List do
  let(:collection_ref) { '12345' }
  let(:folder) { 'subfolder' }
  let(:s3) { instance_double(Aws::S3::Resource, bucket: bucket) }
  let(:bucket) { double('Bucket', objects: objects) }
  let(:objects) { [double('Object', key: '12345/subfolder/test123.txt', last_modified: '2016-12-01T16:26:44.000Z')] }

  subject { described_class.new(collection_ref, folder: folder) }

  describe '#files' do
    before do
      allow(subject).to receive(:s3).and_return(s3)
    end

    let(:expected_files_hash) {
      {
        collection: collection_ref,
        folder: folder,
        files: [
          {key: '12345/subfolder/test123.txt', title: 'test123.txt', last_modified: '2016-12-01T16:26:44.000Z'}
        ]
      }
    }

    it 'list S3 bucket objects by their collection reference including a trailing slash' do
      expect(bucket).to receive(:objects).with(prefix: '12345/subfolder/')
      files = subject.files
      expect(files).to eq(expected_files_hash)
    end

    context 'when no folder is given' do
      let(:expected_files_hash) {
        {
          collection: collection_ref,
          folder: folder,
          files: [
            {key: '12345/test123.txt', title: 'test123.txt', last_modified: '2016-12-01T16:26:44.000Z'}
          ]
        }
      }
      let(:objects) { [double('Object', key: '12345/test123.txt', last_modified: '2016-12-01T16:26:44.000Z')] }
      let(:folder) { nil }

      it 'list S3 bucket objects by their collection reference including a trailing slash' do
        expect(bucket).to receive(:objects).with(prefix: '12345/')
        files = subject.files
        expect(files).to eq(expected_files_hash)
      end
    end
  end
end
