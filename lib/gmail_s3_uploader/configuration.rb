require 'yaml'

class Configuration

  def initialize(config_file=nil)
    @config_hash = Hash.new()
    @config_file = config_file
    if config_file.nil?
      @config_file = 'gmail2s3_config.yml'
    end
    load(@config_file)
  end

  # TODO: implement gmail diagnostic
  def diagnostic()
    aws_check = AWSS3.diagnotics()
  end

  # Adds to configuration hash
  # TODO: Implement parent
  def add_field(hash_tag, prompt_msg, parent=nil)
    print "\n#{prompt_msg} "
    user_reply = gets.chomp
    @config_hash[hash_tag] = user_reply
  end

  # Saves hash into YAML file
  def save()
    if File.exists?(@config_file)
      print("\nOverwrite existing configuration file? (#{@config_file})")
      if /No|no|n/ =~ gets.chomp
        return
      end
    end
    File.open(@config_file ,"w") do |file|
      file.write @config_hash.to_yaml
    end
  end

  # Save key-value pairs into different format, not YAML.
  def save_as()

  end

  def show()
    puts @config_hash
  end

  def load(fname)
    if File.exists?(fname)
      @config_hash = YAML.load(File.open(fname))
    end
  end

  def check_aws_config()

  end

  def check_gmail_config()

  end

end