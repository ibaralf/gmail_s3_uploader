# Wrap for AWS calls
require 'uuid'
require 'aws-sdk'

# TODO: A lot (Download, catch exceptions, clean up, logger)
class AWSS3

  DEFAULT_AWS_DIRECTORY = Dir.home + '/.aws/rootkey.csv'
  # Searches for AWS credentials in ~/.aws/rootkey.csv
  # Pass a hash with :access_key, :secret, :region
  # to override
  def initialize(auth_hash = nil, region = 'us-west-1')
    if ! auth_hash.nil?
      access_key = auth_hash[:access_key]
      secret = auth_hash[:secret]
      region = auth_hash[:region].nil? ? region : auth_hash[:region]
    else
      File.open(DEFAULT_AWS_DIRECTORY) do |file|
        file.each do |line|
          if /AWSAccessKeyId=(.*)/ =~ line
            access_key = $1
          elsif /AWSSecretKey=(.*)/ =~ line
            secret = $1
          elsif /Region=(.*)/ =~ line
            region = $1
          end
        end
      end
    end
    create_s3(access_key, secret, region)
  end

  #authenticates to S3
  def create_s3(access_key, access_secret, region = 'us-west-1')
    @s3 = Aws::S3::Resource.new(
        credentials: Aws::Credentials.new(access_key, access_secret), region: region)
  end

  def upload_all_files(folder_path, bucket_name='randomize')
    if bucket_name =='randomize'
      bucket_name = "ThredUP" + uuid.generate
    end
    s3_bucket = create_bucket(bucket_name)
    Dir.glob(folder_path + '/**/*').select do |file|
      puts "FOUND: #{file}"
      if File.file? file
        upload_file(s3_bucket, file)
      end
    end

  end

  # TODO: check if exists rather than force exception
  #
  def create_bucket(bucket_name)
    bucket_obj = nil
    begin
      bucket_obj = @s3.bucket(bucket_name)
      bucket_obj.create()
    rescue Aws::S3::Errors::BucketAlreadyOwnedByYou
      puts "Bucket already owned - #{bucket_name}"
    rescue Aws::S3::Errors::InvalidBucketName
      puts "Bucket name invalid - #{bucket_name}"
    rescue Aws::S3::Errors::BucketAlreadyExists
      puts "Bucket name exists - #{bucket_name}"
    end
    return bucket_obj
  end

  # TODO: Check exceptions
  def upload_file(bucket_obj, filename)
    puts "Uploading #{filename}"
    basename = File.basename(filename)
    bucket_key = bucket_obj.object(basename)
    bucket_key.upload_file(filename)
  end


  private


end