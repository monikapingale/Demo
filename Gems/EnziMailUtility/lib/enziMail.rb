require 'mail'
class MailUtility
  @options = nil
  def initialize(userName,password)
    options = { :address              => "smtp.gmail.com",
                 :port                 => 587,
                 :domain               => 'gmail.com',
                 :user_name            => "#{userName}",
                 :password             => "#{password}",
                 :authentication       => 'plain',
                 :enable_starttls_auto => true  }
    @options = options
    Mail.defaults do
      delivery_method :smtp, options
    end

  end

  def sendMail(recipient,content)
    fromEmail = @options.to_h[:user_name]
    puts fromEmail
    Mail.deliver do
      to "#{recipient}"
      from fromEmail
      subject 'Failure while executing automated test cases'
      body "Hello Team,\n\tPlease take a look of following attachment as it contains failed test cases while doing automation testing."
      add_file "#{content}"
    end
  end
end