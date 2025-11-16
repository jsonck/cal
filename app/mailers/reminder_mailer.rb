class ReminderMailer < ApplicationMailer
  default from: ENV.fetch('SMTP_FROM_EMAIL', 'noreply@calendarreminders.com')

  def event_reminder(event)
    @event = event
    @user = event.user

    mail(
      to: @user.email,
      subject: "Reminder: #{@event.summary} in 1 hour"
    )
  end
end
