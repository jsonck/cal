require 'google/apis/calendar_v3'
require 'googleauth'

class GoogleCalendarService
  def initialize(user)
    @user = user
    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.authorization = authorization
  end

  def fetch_upcoming_events(max_results: 50)
    return [] unless @service.authorization

    begin
      calendar_id = 'primary'
      response = @service.list_events(
        calendar_id,
        max_results: max_results,
        single_events: true,
        order_by: 'startTime',
        time_min: Time.now.iso8601,
        time_max: 1.month.from_now.iso8601
      )

      sync_events(response.items) if response.items
      response.items
    rescue Google::Apis::AuthorizationError => e
      Rails.logger.error "Authorization error for user #{@user.id}: #{e.message}"
      refresh_token!
      retry
    rescue => e
      Rails.logger.error "Error fetching calendar events for user #{@user.id}: #{e.message}"
      []
    end
  end

  def sync_events(google_events)
    google_events.each do |google_event|
      CalendarEvent.create_or_update_from_google(@user, google_event)
    end
  end

  private

  def authorization
    return nil if @user.access_token.blank?

    auth = Signet::OAuth2::Client.new(
      client_id: ENV['GOOGLE_CLIENT_ID'],
      client_secret: ENV['GOOGLE_CLIENT_SECRET'],
      token_credential_uri: 'https://oauth2.googleapis.com/token',
      access_token: @user.access_token,
      refresh_token: @user.refresh_token,
      expires_at: @user.token_expires_at
    )

    # Refresh if expired
    if @user.token_expired? && @user.refresh_token.present?
      auth.refresh!
      @user.update(
        access_token: auth.access_token,
        token_expires_at: auth.expires_at
      )
    end

    auth
  end

  def refresh_token!
    auth = authorization
    auth.refresh!
    @user.update(
      access_token: auth.access_token,
      token_expires_at: auth.expires_at
    )
    @service.authorization = auth
  end
end
