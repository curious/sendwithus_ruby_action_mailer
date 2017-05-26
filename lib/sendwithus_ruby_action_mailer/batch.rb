module SendWithUsMailer
  # Use the SendWithUs Api to send multiple emails
  # The `emails` argument should be an array of SendWithUsMailers
  def self.batch_deliver(emails)
    SendWithUs::Api.new.send_emails(
      emails.map(&:mail_params)
    )
  end
end
