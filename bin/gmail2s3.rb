#require 'gmail_s3_uploader'
require_relative '../lib/gmail_s3_uploader/gmailer'
require_relative '../lib/gmail_s3_uploader/awss3'
require_relative '../lib/gmail_s3_uploader/configuration'
require_relative '../lib/gmail_s3_uploader/argument'

upload_file = Dir.pwd + '/attachments/schnauzer.jpeg'
upload_folder = Dir.pwd + '/attachments'
bucket_name = "chetana123123123"


def read_arguments(user_args)
  @argument = Argument.new(user_args)

end

def get_configurations()
  @configurator = Configuration.new('config.yml')
  @configurator.diagnostic

  @configurator.add_field('email', 'Enter Gmail Account:')
  @configurator.add_field('access_key', 'Enter Access Key for account:')
  @configurator.add_field('secret', 'Enter Secret for access key:')
  @configurator.show
  @configurator.save
end

read_arguments(ARGV)

#get_configurations



exit(0)



# MAIN
@gmail = Gmailer.new('some_gmail_address@gmail.com', 'your_password')

@gmail.save_attachments()


@awss3 = AWSS3.new(nil)
@awss3.upload_all_files(upload_folder, bucket_name)

