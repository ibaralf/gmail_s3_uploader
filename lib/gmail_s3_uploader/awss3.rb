# Wrap for AWS calls
require 'uuid'
require 'aws-sdk'

# TODO: A lot (Download, catch ALL exceptions, clean up, logger)
class AWSS3

  DEFAULT_REGION = 'us-west-1'
  DEFAULT_AWS_DIRECTORY = Dir.home + '/.aws/rootkey.csv'
  # Searches for AWS credentials in ~/.aws/rootkey.csv
  # Pass a hash with :access_key, :secret, :region
  # to override
  def initialize(auth_hash = nil, region = DEFAULT_REGION)
    if ! auth_hash.nil?
      access_key = auth_hash[:access_key]
      secret = auth_hash[:secret]
      region = auth_hash[:region].nil? ? region : auth_hash[:region]
    else
      # File.open(DEFAULT_AWS_DIRECTORY) do |file|
      #   file.each do |line|
      #     if /AWSAccessKeyId=(.*)/ =~ line
      #       access_key = $1
      #     elsif /AWSSecretKey=(.*)/ =~ line
      #       secret = $1
      #     elsif /Region=(.*)/ =~ line
      #       region = $1
      #     end
      #   end
      # end
      config_from_file = self.class.read_config
      if config_from_file.nil?
        puts "ERROR: No AWS configuration - run XXXX"
        exit(1)
      end
      access_key = config_from_file[:access_key]
      secret = config_from_file[:secret]
      region = config_from_file[:region].nil? ? region : config_from_file[:region]
    end
    create_s3(access_key, secret, region)
  end

  #authenticates to S3
  # TODO: Catch exceptions then exit
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
    success = false
    bucket_obj = nil
    begin
      bucket_obj = @s3.bucket(bucket_name)
      bucket_obj.create()
      success = true
    rescue Aws::S3::Errors::BucketAlreadyOwnedByYou
      puts "Bucket already owned - #{bucket_name}"
    rescue Aws::S3::Errors::InvalidBucketName
      puts "Bucket name invalid - #{bucket_name}"
    rescue Aws::S3::Errors::BucketAlreadyExists
      puts "Bucket name exists - #{bucket_name}"
    rescue Aws::S3::Errors::InvalidAccessKeyId
      puts "Invalid AWS Credentials"
    rescue Aws::S3::Errors::SignatureDoesNotMatch
      puts "Signature match error - #{bucket_name}"
    end
    if ! success
      return nil
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

  def self.diagnotics()
    config_from_file = read_config
    if config_from_file.nil?
      return false
    else
      puts "USED: #{config_from_file}"
      s3_connect = Aws::S3::Resource.new(
          credentials: Aws::Credentials.new(config_from_file[:access_key], config_from_file[:secret]), region: config_from_file[:region])
      tbucket = s3_connect.bucket('ibarratestbucket65758')
      begin
        tbucket.create()
      rescue Aws::S3::Errors::InvalidAccessKeyId
        puts "ERROR: Cannot connect to AWS S3 - check AWS credentials"
        return false
      rescue Aws::S3::Errors::SignatureDoesNotMatch
        puts "ERROR: Signature error"
        return false
      rescue Aws::S3::Errors::BucketAlreadyOwnedByYou
        puts "Bucket already owned "
      rescue Aws::S3::Errors::BucketAlreadyExists
        puts "Bucket name exists "
      end
      tbucket.delete
    end
    puts "AWS Works!!!"
    return true
  end

  private

  # Returns hash of configuration
  def self.read_config()
    aws_config_hash = nil

    if File.exists?(DEFAULT_AWS_DIRECTORY)
      aws_config_hash = {:access_key => nil, :secret => nil, :region => nil}
      File.open(DEFAULT_AWS_DIRECTORY) do |file|
        file.each do |line|
          if /AWSAccessKeyId=(.*)/ =~ line
            aws_config_hash[:access_key] = $1
          elsif /AWSSecretKey=(.*)/ =~ line
            aws_config_hash[:secret] = $1
          elsif /Region=(.*)/ =~ line
            aws_config_hash[:region] = $1
          end
        end
      end
      if aws_config_hash[:region].nil?
        aws_config_hash[:region] = DEFAULT_REGION
      end
    end

    return aws_config_hash
  end

end