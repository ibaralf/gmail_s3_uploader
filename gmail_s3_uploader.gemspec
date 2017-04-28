# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gmail_s3_uploader/version'

Gem::Specification.new do |spec|
  spec.name          = "gmail_s3_uploader"
  spec.version       = GmailS3Uploader::VERSION
  spec.authors       = ["Chetana Yogeesh", "Ibarra Alfonso"]
  spec.email         = ["chetana.yogeesh@thredup.com", "ibarra.alfonso@gmail.com"]

  spec.summary       = %q{Uploads gmail attachments to AWS S3}
  spec.description   = %q{Summary says it all.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  #spec.add_development_dependency "rake", "~> 10.0"
  #spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "gmail", "~> 0.6"
  spec.add_development_dependency "aws-sdk", "~> 3.0"
  spec.add_development_dependency "uuid", "~> 2.3"

end
