# Parses command line argument and creates object to have access to arguments
# in your application
# To Add New Parameter:
#   => Add new tag in @valid_parameters
#   => Change HELP message to describe new parameter added
# 4/28/2017 Created  ibarra.alfonso@gmail.com
#
class Argument

  @usage = "Usage: \n  gmail2s3 [-h] [-doctor] \n"
  @help = "    -h, Show help
    -doctor, checks setup and configuration"

  @required = "\nMissing required parameter/s (until config file implemented):
    -c, name of spec file to create
    -f, list of spec files to open"

  # Constructor. Requires passing the parameters from the command line argument.
  #
  def initialize(passed_arguments)
    @valid_parameters = ['-doctor']
    @required_parameters = []
    @requires_atleast_one = []
    check_help(passed_arguments)
    initialize_holder()
    parse_args(passed_arguments)
    check_required_parameters()
    print_arguments
  end

  def print_arguments()
    puts "\nPassed Arguments:"
    @holder.each do |hold|
      if hold[:value] != ""
        puts "  #{hold[:tag]} #{hold[:value]}"
      end
    end
  end

  def parse_args(arguments)
    par_index = []
    @valid_parameters.each do |tag|
      puts "TAG: #{tag}  =>  #{arguments}"
      arg_index = arguments.index(tag).nil? ? -1 : arguments.index(tag)
      par_index.push(arg_index)
    end
    puts "INDEX: #{par_index}"
    @valid_parameters.each_with_index do |tag, x|
      tag_index = par_index[x]
      end_index = get_next_highest(tag_index, par_index)
      save_arg_to_holder(arguments, tag_index, end_index)
    end
  end

  # Returns the argument parameter passed with the specified tag
  #
  def get_arg_value(tag)
    tag_value = nil
    if @valid_parameters.include?(tag)
      tag_hash = @holder.detect{|tag_data| tag_data[:tag] == tag}
      tag_value = tag_hash[:value]
    else
      puts "ERROR: Parameter #{tag} not recognized."
    end
    return tag_value
  end


  private

  # Creates an array of hash to hold values of possible parameter tags.
  # All values are empty.
  def initialize_holder()
    @holder = []
    @valid_parameters.each do |tag|
      param_hash = {:tag => tag, :value => ""}
      @holder.push(param_hash)
    end
  end

  # Returns the next highest value in the array
  # If num is the highest, then returns 100
  def get_next_highest(num, array_num)
    retval = nil
    if ! num.nil? && num != -1
      arr_size = array_num.size
      sorted_nums = array_num.sort
      num_index = sorted_nums.index(num)
      if num_index == arr_size - 1
        retval = 100
      else
        retval = sorted_nums[num_index + 1]
      end
    end
    return retval
  end

  def save_arg_to_holder(arguments, startx, endx)
    if startx >= 0
      which_tag = arguments[startx]
      tag_hash = @holder.detect{|tag_data| tag_data[:tag] == which_tag}
      tag_hash[:value] = arguments[startx+1..endx-1].join(" ")
      puts "SAVED: #{tag_hash}"
    end
  end

  def check_help(arguments)
    if arguments.include?('-h')
      puts "#{@usage}"
      puts "#{@help} \n\n"
      exit(0)
    end
  end

  private

  # Verifies that all required parameters are passed in the argument.
  # Two types of required. First, parameters that are absolutely needed.
  # Second, parameters that are not all required but at least one must
  # be passed.
  # Exits the script if parameter requirements are not satisfied.
  #
  def check_required_parameters()
    params_good = true
    @required_parameters.each do |req_par|
      passed_reqpar = get_arg_value(req_par)
      if passed_reqpar.nil? || passed_reqpar == ""
        params_good = false
      end
    end

    has_atleast_one = true
    if @requires_atleast_one.size > 0
      has_atleast_one = false
      @requires_atleast_one.each do |least_one|
        luno = get_arg_value(least_one)
        if ! luno.nil? && luno != ""
          has_atleast_one = true
        end
      end
    end

    if !params_good || ! has_atleast_one
      puts "Missing parameters: #{@required} #{params_good}  && #{has_atleast_one}"
      exit(1)
    end

  end

end