# services/sms_service.rb
require 'twilio-ruby'
require 'dotenv'
Dotenv.load

class SMSService
  def self.send_sms(to, body)
    account_sid = ENV['TWILIO_ACCOUNT_SID']  # Ensure this is set in your .env
    auth_token = ENV['TWILIO_AUTH_TOKEN']  # Ensure this is set in your .env
    client = Twilio::REST::Client.new(account_sid, auth_token)

    from = ENV['TWILIO_PHONE_NUMBER']   # Ensure this is set in your .env
    to = ENV['SELLER_PHONE_NUMBER']  # Ensure this is set in your .env

    client.messages.create(
      from: from,
      to: to,
      body: body
    )
  end
end
