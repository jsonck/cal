class CalendarEvent < ApplicationRecord
  belongs_to :user

  validates :event_id, presence: true, uniqueness: { scope: :user_id }
  validates :start_time, presence: true

  scope :upcoming, -> { where("start_time > ?", Time.current) }
  scope :needs_reminder, -> { where(reminder_sent: false).where("start_time BETWEEN ? AND ?", 1.hour.from_now, 2.hours.from_now) }

  def self.create_or_update_from_google(user, google_event)
    event_id = google_event.id
    start_time = parse_time(google_event.start)
    end_time = parse_time(google_event.end)

    find_or_initialize_by(user: user, event_id: event_id).tap do |event|
      event.summary = google_event.summary
      event.start_time = start_time
      event.end_time = end_time
      event.save
    end
  end

  def self.parse_time(time_obj)
    return nil unless time_obj
    time_obj.date_time || DateTime.parse(time_obj.date.to_s) rescue nil
  end
end
