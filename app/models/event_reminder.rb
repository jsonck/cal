class EventReminder < ApplicationRecord
  belongs_to :calendar_event

  validates :minutes_before, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 1440 } # Max 24 hours
  validates :notification_type, inclusion: { in: %w[email sms both] }

  scope :pending, -> { where(sent: false) }
  scope :needing_send, -> {
    pending
      .joins(:calendar_event)
      .where('calendar_events.start_time BETWEEN ? AND ?',
             Time.current,
             24.hours.from_now)
      .where('calendar_events.start_time <= ?',
             Arel.sql('NOW() + (event_reminders.minutes_before || \' minutes\')::interval'))
  }

  def ready_to_send?
    return false if sent?
    return false unless calendar_event.start_time

    send_at = calendar_event.start_time - minutes_before.minutes
    Time.current >= send_at
  end

  def mark_sent!
    update(sent: true)
  end
end
