# Google Calendar Reminder App

A Rails application that integrates with Google Calendar to automatically send email reminders 1 hour before calendar events.

## Features

- OAuth2 authentication with Google Calendar (read-only access)
- **Real-time webhook notifications** for instant calendar updates
- Automatic calendar synchronization every 6 hours (backup)
- Email reminders sent 1 hour before each event
- RESTful API built with Grape
- Background job processing with Sidekiq
- Scheduled tasks using Sidekiq Scheduler
- Ready for Google Marketplace deployment

## Tech Stack

- Ruby 3.2+
- Rails 7.2+
- PostgreSQL
- Redis
- Sidekiq (background jobs)
- Grape (API framework)
- Google Calendar API
- OmniAuth Google OAuth2

## Prerequisites

- Ruby 3.2 or higher
- PostgreSQL
- Redis server
- Google Cloud Platform account (for OAuth credentials)

## Setup Instructions

### 1. Install Dependencies

```bash
bundle install
```

### 2. Configure Google OAuth

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google Calendar API
4. Go to "Credentials" and create OAuth 2.0 credentials
5. Set authorized redirect URIs:
   - `http://localhost:3000/auth/google_oauth2/callback` (development)
   - Your production domain callback URL (production)
6. Copy the Client ID and Client Secret

### 3. Environment Variables

Copy the example environment file and configure it:

```bash
cp .env.example .env
```

Edit `.env` and add your credentials:

```
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
APP_URL=https://yourdomain.com  # Required for webhooks (use ngrok for local dev)
REDIS_URL=redis://localhost:6379/0
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_DOMAIN=yourdomain.com
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_app_password
SMTP_FROM_EMAIL=noreply@yourdomain.com
```

**Note**: For webhook support, `APP_URL` must be a publicly accessible HTTPS URL. See [WEBHOOK_SETUP.md](WEBHOOK_SETUP.md) for details.

### 4. Database Setup

```bash
rails db:create
rails db:migrate
```

### 5. Start Redis

```bash
redis-server
```

### 6. Start Sidekiq

In a separate terminal:

```bash
bundle exec sidekiq
```

### 7. Start Rails Server

```bash
rails server
```

Visit `http://localhost:3000` to access the application.

## How It Works

1. **Authentication**: Users authenticate via Google OAuth2 with Calendar.readonly scope
2. **Calendar Sync**: Upon authentication, the app syncs upcoming events (next 30 days)
3. **Webhook Setup**: A watch is created to receive real-time calendar change notifications
4. **Real-time Updates**: When events change, Google sends a webhook notification triggering immediate sync
5. **Automatic Sync**: Every 6 hours, all user calendars are re-synced (backup for failed webhooks)
6. **Watch Renewal**: Daily job renews watches before they expire (~7 days)
7. **Reminder Check**: Every 15 minutes, the app checks for events starting in 1 hour
8. **Email Delivery**: Reminder emails are sent via background jobs

For detailed webhook setup instructions, see [WEBHOOK_SETUP.md](WEBHOOK_SETUP.md).

## API Endpoints

The app includes a Grape API mounted at `/api/v1`:

### Authentication
- `GET /api/v1/auth/status` - Check auth status
- `GET /api/v1/auth/oauth_url` - Get OAuth URL

### Users
- `GET /api/v1/users/me?user_id=1` - Get current user info
- `GET /api/v1/users/events?user_id=1` - Get user's upcoming events

## Background Jobs

### Sidekiq Jobs

- `CalendarSyncJob` - Syncs a single user's calendar
- `SyncAllCalendarsJob` - Syncs all users' calendars (runs every 6 hours)
- `CheckRemindersJob` - Checks for events needing reminders (runs every 15 minutes)
- `SendReminderJob` - Sends individual reminder emails
- `SetupWatchJob` - Sets up webhook watch for a user
- `RenewWatchesJob` - Renews expiring webhook watches (runs daily)

### Monitoring Sidekiq

Visit `http://localhost:3000/sidekiq` to access the Sidekiq web UI (in production, protect this route with authentication).

## Email Configuration

### Development

For development, you can use:
- [Mailcatcher](https://mailcatcher.me/) - Local SMTP server with web interface
- Gmail SMTP with an app password
- Any other SMTP service

### Production

Configure your production SMTP settings in the environment variables. Recommended services:
- SendGrid
- Mailgun
- Amazon SES
- Postmark

## Deployment

### Preparing for Google Marketplace

1. **OAuth Consent Screen**: Configure your OAuth consent screen in Google Cloud Console
2. **Scopes**: Ensure `https://www.googleapis.com/auth/calendar.readonly` is included
3. **Verification**: Submit your app for verification if needed
4. **Privacy Policy**: Add a privacy policy URL
5. **Terms of Service**: Add terms of service URL

### Production Deployment Checklist

- [ ] Set all environment variables
- [ ] Configure production database
- [ ] Set up Redis server
- [ ] Configure email SMTP settings
- [ ] Run database migrations
- [ ] Precompile assets: `rails assets:precompile`
- [ ] Start Sidekiq workers
- [ ] Configure SSL/HTTPS
- [ ] Set up monitoring and logging
- [ ] Add authentication to Sidekiq web UI

### Heroku Deployment Example

```bash
# Create Heroku app
heroku create your-app-name

# Add PostgreSQL
heroku addons:create heroku-postgresql:mini

# Add Redis
heroku addons:create heroku-redis:mini

# Set environment variables
heroku config:set GOOGLE_CLIENT_ID=your_id
heroku config:set GOOGLE_CLIENT_SECRET=your_secret
# ... set other env vars

# Deploy
git push heroku main

# Run migrations
heroku run rails db:migrate

# Scale Sidekiq worker
heroku ps:scale worker=1
```

Create a `Procfile`:
```
web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq
```

## Project Structure

```
app/
├── api/              # Grape API
│   └── v1/
│       ├── base.rb
│       ├── auth.rb
│       └── users.rb
├── controllers/      # Rails controllers
│   ├── sessions_controller.rb
│   └── home_controller.rb
├── jobs/            # Sidekiq jobs
│   ├── calendar_sync_job.rb
│   ├── send_reminder_job.rb
│   ├── check_reminders_job.rb
│   └── sync_all_calendars_job.rb
├── mailers/         # Email mailers
│   └── reminder_mailer.rb
├── models/          # ActiveRecord models
│   ├── user.rb
│   └── calendar_event.rb
└── services/        # Business logic
    └── google_calendar_service.rb
```

## Security Considerations

- OAuth tokens are stored encrypted in the database
- Only Calendar.readonly scope is requested
- CSRF protection enabled
- SSL/HTTPS enforced in production
- Secure session cookies
- Environment variables for sensitive data

## Future Enhancements

- SMS reminders (Twilio integration)
- Customizable reminder times
- Multiple reminders per event
- Web push notifications
- User preferences dashboard
- Calendar selection (multiple calendars)
- Timezone support improvements

## License

This project is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Support

For issues and questions, please open an issue on GitHub.
