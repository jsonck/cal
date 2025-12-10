class SettingsController < ApplicationController
  before_action :require_user

  def show
    @user = current_user
  end

  def update
    @user = current_user
    params_hash = user_params

    # Handle SMS consent timestamp and auto-disable SMS if consent is removed
    if params_hash[:sms_consent] == '1' && !@user.sms_consent?
      @user.sms_consent_date = Time.current
    elsif params_hash[:sms_consent] == '0' || params_hash[:sms_consent] == false
      # When consent is removed, automatically disable SMS
      @user.sms_consent_date = nil
      params_hash[:sms_enabled] = false
    end

    if @user.update(params_hash)
      redirect_to settings_path, notice: "Settings updated successfully!"
    else
      flash.now[:alert] = @user.errors.full_messages.join(', ')
      render :show
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
    params.require(:user).permit(:phone_number, :sms_enabled, :notification_method, :sms_consent)
  end
end
