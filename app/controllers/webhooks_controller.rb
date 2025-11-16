class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def google_calendar
    channel_id = request.headers['X-Goog-Channel-ID']
    resource_state = request.headers['X-Goog-Resource-State']
    resource_id = request.headers['X-Goog-Resource-ID']

    Rails.logger.info "Received webhook - Channel: #{channel_id}, State: #{resource_state}, Resource: #{resource_id}"

    # Handle sync message (sent when watch is created or about to expire)
    if resource_state == 'sync'
      Rails.logger.info "Sync message received for channel #{channel_id}"
      head :ok
      return
    end

    # Find the watch
    watch = Watch.find_by(channel_id: channel_id, resource_id: resource_id)

    unless watch
      Rails.logger.warn "Watch not found for channel #{channel_id}"
      head :not_found
      return
    end

    # Trigger calendar sync for this user
    if resource_state == 'exists'
      Rails.logger.info "Calendar changed for user #{watch.user_id}, triggering sync"
      CalendarSyncJob.perform_async(watch.user_id)
    end

    head :ok
  rescue => e
    Rails.logger.error "Error processing webhook: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    head :internal_server_error
  end
end
