class RenewWatchesJob
  include Sidekiq::Job

  def perform
    Rails.logger.info "Starting watch renewal check"

    webhook_url = "#{ENV['APP_URL']}/webhooks/google_calendar"
    renewed_count = 0
    failed_count = 0

    # Find all watches expiring in the next 24 hours
    Watch.expiring_soon.each do |watch|
      user = watch.user
      service = GoogleCalendarService.new(user)

      Rails.logger.info "Renewing watch #{watch.channel_id} for user #{user.id}"

      result = service.renew_watch(watch, webhook_url)

      if result
        renewed_count += 1
        Rails.logger.info "Successfully renewed watch for user #{user.id}"
      else
        failed_count += 1
        Rails.logger.error "Failed to renew watch for user #{user.id}"
      end
    end

    # Deactivate expired watches
    Watch.expired.each do |watch|
      Rails.logger.warn "Deactivating expired watch #{watch.channel_id}"
      watch.deactivate!
    end

    Rails.logger.info "Watch renewal complete - Renewed: #{renewed_count}, Failed: #{failed_count}"
  end
end
