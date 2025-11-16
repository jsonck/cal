class SyncAllCalendarsJob
  include Sidekiq::Job

  def perform
    Rails.logger.info "Syncing calendars for all users"

    User.find_each do |user|
      CalendarSyncJob.perform_async(user.id)
    end
  end
end
