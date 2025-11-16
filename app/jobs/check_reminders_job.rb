class CheckRemindersJob
  include Sidekiq::Job

  def perform
    Rails.logger.info "Checking for event reminders that need to be sent"

    # Find all event reminders that are ready to send
    reminders_to_send = EventReminder.pending
      .joins(:calendar_event)
      .where('calendar_events.start_time > ?', Time.current)
      .where('calendar_events.start_time <= ?', 24.hours.from_now)
      .select { |reminder| reminder.ready_to_send? }

    reminders_to_send.each do |reminder|
      SendReminderJob.perform_async(reminder.id)
    end

    Rails.logger.info "Queued #{reminders_to_send.count} reminder(s)"
  end
end
