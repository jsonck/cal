class CalendarSyncJob
  include Sidekiq::Job

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    Rails.logger.info "Syncing calendar for user #{user.id}"

    service = GoogleCalendarService.new(user)
    service.fetch_upcoming_events
  end
end
