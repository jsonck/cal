class CheckRemindersJob
  include Sidekiq::Job

  def perform
    Rails.logger.info "Checking for events that need reminders"

    # Find all events that need reminders (1 hour before start time)
    events = CalendarEvent.needs_reminder

    events.each do |event|
      SendReminderJob.perform_async(event.id)
    end

    Rails.logger.info "Queued #{events.count} reminder(s)"
  end
end
