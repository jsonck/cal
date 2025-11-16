class EventRemindersController < ApplicationController
  before_action :require_user
  before_action :set_event

  def index
    @reminders = @event.event_reminders.order(:minutes_before)
  end

  def create
    @reminder = @event.event_reminders.build(reminder_params)
    @reminder.notification_type ||= current_user.notification_method

    if @event.event_reminders.count >= 4
      redirect_to root_path, alert: "Maximum 4 reminders per event"
      return
    end

    if @reminder.save
      redirect_to root_path, notice: "Reminder added!"
    else
      redirect_to root_path, alert: "Error adding reminder: #{@reminder.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @reminder = @event.event_reminders.find(params[:id])
    @reminder.destroy
    redirect_to root_path, notice: "Reminder removed"
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_user
    unless current_user
      redirect_to root_path, alert: "Please sign in first"
    end
  end

  def set_event
    @event = current_user.calendar_events.find(params[:event_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Event not found"
  end

  def reminder_params
    params.require(:event_reminder).permit(:minutes_before, :notification_type)
  end
end
