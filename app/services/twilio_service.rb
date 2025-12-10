require 'twilio-ruby'

class TwilioService
  def initialize
    @client = Twilio::REST::Client.new(
      ENV['TWILIO_ACCOUNT_SID'],
      ENV['TWILIO_AUTH_TOKEN']
    )
    @from_number = ENV['TWILIO_PHONE_NUMBER']
  end

  def send_reminder(user, event)
    return unless user.phone_number.present?
    return unless user.sms_enabled?
    return unless user.sms_consent?

    message_body = format_reminder_message(event)

    begin
      @client.messages.create(
        from: @from_number,
        to: user.phone_number,
        body: message_body
      )

      Rails.logger.info "SMS sent to #{user.phone_number} for event #{event.id}"
      true
    rescue Twilio::REST::RestError => e
      Rails.logger.error "Twilio error sending SMS to #{user.phone_number}: #{e.message}"
      false
    rescue => e
      Rails.logger.error "Error sending SMS to #{user.phone_number}: #{e.message}"
      false
    end
  end

  private

  def format_reminder_message(event)
    time_str = event.start_time.strftime('%l:%M %p on %b %d, %Y')
    "Reminder: #{event.summary} starts at #{time_str}"
  end
end
