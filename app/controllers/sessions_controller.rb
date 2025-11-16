class SessionsController < ApplicationController
  def create
    auth = request.env['omniauth.auth']
    user = User.from_omniauth(auth)

    if user.persisted?
      user.update_tokens(auth.credentials)
      session[:user_id] = user.id

      # Trigger initial calendar sync
      CalendarSyncJob.perform_async(user.id)

      redirect_to root_path, notice: "Successfully authenticated with Google Calendar!"
    else
      redirect_to root_path, alert: "Authentication failed. Please try again."
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Signed out successfully."
  end

  def failure
    redirect_to root_path, alert: "Authentication failed: #{params[:message]}"
  end
end
