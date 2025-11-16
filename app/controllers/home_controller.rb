class HomeController < ApplicationController
  def index
    @user = current_user
    @events = @user&.calendar_events&.upcoming&.order(:start_time)&.limit(10) || []
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end
end
