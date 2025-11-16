class SettingsController < ApplicationController
  before_action :require_user

  def show
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      redirect_to settings_path, notice: "Settings updated successfully!"
    else
      render :show, alert: "Error updating settings"
    end
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

  def user_params
    params.require(:user).permit(:phone_number, :sms_enabled, :notification_method)
  end
end
