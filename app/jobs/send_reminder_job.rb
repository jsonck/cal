class SendReminderJob
  include Sidekiq::Job

  def perform(reminder_id)
    reminder = EventReminder.find_by(id: reminder_id)
    return unless reminder
    return if reminder.sent?

    event = reminder.calendar_event
    user = event.user
    notification_type = reminder.notification_type

    # Send email if needed
    if notification_type.in?(['email', 'both'])
      ReminderMailer.event_reminder(event).deliver_now
      Rails.logger.info "Sent email reminder for event #{event.id} to #{user.email}"
    end

    # Send SMS if needed
    if notification_type.in?(['sms', 'both'])
      if user.phone_number.present? && user.sms_enabled
        twilio = TwilioService.new
        twilio.send_reminder(user, event)
        Rails.logger.info "Sent SMS reminder for event #{event.id} to #{user.phone_number}"
      else
        Rails.logger.warn "Cannot send SMS for event #{event.id}: user #{user.id} has no phone number or SMS disabled"
      end
    end

    # Mark reminder as sent
    reminder.mark_sent!

    Rails.logger.info "Completed reminder #{reminder.id} for event #{event.id}"
  end
end
