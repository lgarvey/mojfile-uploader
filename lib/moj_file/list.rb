module MojFile
  class List
    include MojFile::S3

    attr_accessor :collection, :folder

    def self.call(*args)
      new(*args)
    end

    def initialize(collection_ref, folder:)
      @collection = collection_ref
      @folder = folder
    end

    def files
      {
        collection: collection,
        folder: folder,
        files: map_files
      }
    end

    def files?
      !objects.empty?
    end

    private

    def map_files
      objects.map{ |o|
        {
          key: o.key,
          title: o.key.sub(prefix,''),
          last_modified: o.last_modified
        }
      }
    end

    def prefix
      [collection, folder].compact.join('/') + '/'
    end

    def bucket_name
      ENV.fetch('BUCKET_NAME')
    end

    def objects
      @objects ||= s3.bucket(bucket_name).objects(prefix: prefix).to_set
    end
  end
end
