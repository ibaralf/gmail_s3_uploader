require 'gmail'

# Author: ibarra.alfonso@gmail.com
#
# 4/27/2017 Created
#
# TODO: Implement getting welcome email
#       Reset Password
#       Get attachment
class Gmailer

  def initialize(username, password)
    @user = username
    @pw = password
    @is_signed_in = sign_in(username, password)
  end

  def save_attachments(unread_only = true)
    search_hash = {:subject => 'Test Attachment'}
    emails = get_emails(search_hash)
    puts "HOWMANY #{emails.size}"
    emails.each do |email|
      get_email_attachments(email)
    end

  end

  # Mail gem allows email query using Hash (e.g. :subject => 'Some string', :from => 'tacos@bell.com')
  # For details of allowed key fields, see the Gem documentation for Mail.
  # Note: because :unread does not have any :key-:value pair, it needs to be explicitly passed
  #       since hashes requires keys to have a value.
  def get_emails(hash_args, unread_only = true)
    emails = []
    if check_if_signed_in
      if unread_only
        emails = @gmail.inbox.emails(:unread, hash_args)
      else
        emails = @gmail.inbox.emails(hash_args)
      end
      mark_as_read(emails)
    else
      puts "ERROR: Not signed in on GMAIL."
    end
    return emails
  end

  # Returns array of emails found that meets the search criteria. Timeouts in 5 minutes if no emails are found.
  # * *Args*  :
  #   - +search_hash+ -> Hash for searching (e.g. {:subject => "Package sent", :from => "test@example.com"})
  #   - +max_try+ -> Integer, waiting time multiplied by 6 seconds (e.g 5, will wait for 30 seconds.)
  # * *Returns* :
  #   - Array<Gmail:Email> object, if inbox has email that meet the search hash
  #   - Array[] - empty, no email found
  #
  def wait_for_emails(search_hash, max_try=15)
    found_emails = []
    if ! check_if_signed_in
      puts "ERROR Cannot wait_for_email - Cannot sign in to Gmail."
      return found_emails
    end
    puts "EMAIL: Wait for #{search_hash}"
    atmps = 0
    while ! is_found && atmps < max_try do
      emails = @gmail.inbox.emails(search_hash)
      puts "Waiting for emails - #{search_hash}"
      if ! emails.nil? && emails.size > 0
        found_emails = emails
      else
        sleep(6)
      end
      atmps += 1
    end
    return emails
  end

  # Returns the lastest email object that meets the search criteria. Timeouts in
  # 5 minutes if no email is being sent out.
  # * *Args*  :
  #   - +search_has+ -> Hash for searching (e.g. {:subject => "Package sent", :from => "test@example.com"})
  #   - +max_try+ -> Integer, waiting time multiplied by 6 seconds (e.g 5, will wait for 30 seconds.)
  # * *Returns* :
  #   - Gmail:Email object, if inbox has email that meet the search hash
  #   - nil, no email found
  #
  def wait_for_latest_email(search_hash, max_try=50)
    found_email = nil
    if ! check_if_signed_in
      puts "ERROR Cannot wait_for_email - Cannot sign in to Gmail."
      return found_email
    end
    puts "EMAIL: Will wait for #{search_hash}"
    atmps = 0
    while found_email.nil? && atmps < max_try do
      emails = @gmail.inbox.emails(:unread, search_hash)
      puts "Waiting for email - :unread, #{search_hash} #{emails}"
      if ! emails.nil? && emails.size > 0
        found_email = emails.last
        puts "EMAIL Found: #{found_email}"
      else
        sleep(6)
      end
      atmps += 1
    end
    return found_email
  end

  def get_emails_from_sender(sender_email)
    emails = nil
    if check_if_signed_in
      emails = @gmail.inbox.emails(:from => sender_email)
    end
    return emails
  end

  def get_latest_email_from_sender(sender_email)
    last_email = nil
    emails = get_emails_from_sender(sender_email)
    if ! emails.nil?
      last_email = emails.last
    end
    return last_email
  end

  def delete!(email_obj)
    email_action(email_obj, 'delete')
  end

  def read!(email_obj)
    email_action(email_obj, 'read')
  end

  def get_welcome_link(recipient_email, do_after='delete')
    get_email_link(recipient_email, 'welcome', 'welcome', do_after)
  end

  def get_password_reset_link(recipient_email, do_after='delete')
    get_email_link(recipient_email, 'reset', 'reset', do_after)
  end

  def wait_for_welcome_email(recipient_email, email_type)
    shash = {:to => recipient_email, :subject => get_email_subject(email_type)}
    wait_for_latest_email(shash)
  end

  def email_action(email_obj, what_action)
    case(what_action)
      when "delete"
        puts "EMAIL: deleting email - #{email_obj.subject}"
        email_obj.delete!
      when "read"
        puts "EMAIL: marking email as read - #{email_obj.subject}"
        email_obj.read!
    end
  end

  def delete_all_emails(shash)
    @gmail.inbox.find(shash).each do |email|
      puts "GMAIL Deleting email - Subject: #{email.subject}"
      email.delete!
    end
  end

  def sign_out()
    puts "Gmail: User loggin out"
    @gmail.logout
  end

  private

  # TODO: Error checks
  def get_email_attachments(email_obj)
    folder = Dir.pwd + "/attachments"
    puts "SAVING TO #{folder}"
    Dir.mkdir(folder) unless Dir.exist?(folder)
    attachment = email_obj.attachments[0]
    File.write(File.join(folder, attachment.filename), attachment.body.decoded)
    #
    #
    # f = email_obj.message.attachments
    # puts "WHAT F: #{f.class}"
    # File.write(File.join(folder, f.filename), f.body.decoded)
  end

  def sign_in(username, password)
    puts "Signing on to GMAIL: #{username} #{password}"
    @gmail = Gmail.connect(username, password)
    is_signed_in = @gmail.logged_in?
    tries = 0
    while ! is_signed_in && tries < 3
      sleep(2)
      @gmail = Gmail.connect(username, password)
      is_signed_in = @gmail.signed_in?
      tries += 1
    end
    return is_signed_in
  end

  def check_if_signed_in()
    is_signed_in = @gmail.logged_in?
    if ! is_signed_in
      puts "Not signed in Gmail - signing in."
      is_signed_in = sign_in(@user, @pw)
    end
    return is_signed_in
  end

  # Returns the Asperaf Files link sent in the email.
  # * *Args*  :
  #   - +sender_mail+ -> String, email address of the sender
  #   - +subject_search+ -> String, email subject string to find
  #   - +email_type+ -> String, aspera files email type (welcome, package, reset, share, public invite)
  #                     or text that can be found in the email subject.
  # * *Returns* :
  #   - HTML link that was contained in the email
  #   - nil, if no email is found
  #
  def get_email_link(recipient_email, subject_search, email_type, do_after)
    just_link = nil
    shash = {:to => recipient_email, :subject => get_email_subject(subject_search)}
    email_found = wait_for_latest_email(shash)
    puts "EMAIL FOUND: #{email_found}"
    if ! email_found.nil?
      pattern = get_link_pattern(email_type)
      puts "EMAIL Search pattern - #{pattern}"
      puts "EMAIL Search pattern - #{email_found.html_part}"
      match_arr = pattern.match(email_found.html_part.to_s)
      puts "MATCHED: #{match_arr}"
      if ! match_arr.nil? && match_arr.size > 1
        just_link = match_arr[1].gsub("=\r", "").gsub("=3D", '=')
        puts "EMAIL - Got link #{just_link}"
      else
        puts "ERROR Email cannot find link - #{match_arr}"
      end
      email_action(email_found, do_after)
    end
    return just_link
  end

  def mark_as_read(email_array)
    email_array.each do |email|
      puts "Marking email as Read!: #{email.subject}"
      email.read!
    end
  end

  def get_link_pattern(email_type)
    pattern = /\<a.*href=\"(http.*)\"\>Accept.*/
    case(email_type)
      when "welcome"
        pattern = /\<a.*href=3?D?\"(http.*)\"\>Accept.*/m
      when "reset"
        pattern = /\<a.*href=3?D?\"(http.*)\"\>Reset.*/m
    end
    return pattern
  end

  # Gets a string that is a substring of the email subject.
  #
  def get_email_subject(email_type)
    email_subject = email_type
    case(email_type)
      when "welcome"
        email_subject = "Welcome to Aspera Files"
      when "reset"
        email_subject = "Password Reset"
    end
    return email_subject
  end

end