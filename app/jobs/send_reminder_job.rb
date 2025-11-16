class SendReminderJob
  include Sidekiq::Job

  def perform(event_id)
    event = CalendarEvent.find_by(id: event_id)
    return unless event
    return if event.reminder_sent?

    # Send reminder email
    ReminderMailer.event_reminder(event).deliver_now

    # Mark as sent
    event.update(reminder_sent: true)

    Rails.logger.info "Sent reminder for event #{event.id} to user #{event.user.email}"
  end
end
