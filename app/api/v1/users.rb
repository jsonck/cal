module V1
  class Users < Grape::API
    namespace :users do
      desc 'Get current user info'
      params do
        requires :user_id, type: Integer
      end
      get :me do
        user = User.find_by(id: params[:user_id])
        if user
          {
            id: user.id,
            email: user.email,
            created_at: user.created_at
          }
        else
          error!('User not found', 404)
        end
      end

      desc 'Get user calendar events'
      params do
        requires :user_id, type: Integer
      end
      get :events do
        user = User.find_by(id: params[:user_id])
        if user
          events = user.calendar_events.upcoming.order(:start_time).limit(20)
          events.map do |event|
            {
              id: event.id,
              summary: event.summary,
              start_time: event.start_time,
              end_time: event.end_time,
              reminder_sent: event.reminder_sent
            }
          end
        else
          error!('User not found', 404)
        end
      end
    end
  end
end
