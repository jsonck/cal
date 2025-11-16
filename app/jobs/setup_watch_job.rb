class SetupWatchJob
  include Sidekiq::Job

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    # Deactivate any existing active watches for this user
    user.watches.active.each do |watch|
      service = GoogleCalendarService.new(user)
      service.stop_watch(watch)
    end

    # Set up new watch
    service = GoogleCalendarService.new(user)
    webhook_url = "#{ENV['APP_URL']}/webhooks/google_calendar"

    result = service.setup_watch(webhook_url)

    if result
      Rails.logger.info "Successfully set up watch for user #{user.id}"
    else
      Rails.logger.error "Failed to set up watch for user #{user.id}"
    end
  end
end
