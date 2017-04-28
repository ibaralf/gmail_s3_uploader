#require 'gmail_s3_uploader'
require_relative '../lib/gmail_s3_uploader/gmailer'
require_relative '../lib/gmail_s3_uploader/awss3'

upload_file = Dir.pwd + '/attachments/schnauzer.jpeg'
upload_folder = Dir.pwd + '/attachments'
bucket_name = "chetana123123123"

# MAIN
@gmail = Gmailer.new('asperatest.01@gmail.com', 'Jester11')

@gmail.save_attachments()


@awss3 = AWSS3.new(nil)
@awss3.upload_all_files(upload_folder, bucket_name)
