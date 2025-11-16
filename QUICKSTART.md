# Quick Start Guide

Get the Google Calendar Reminder App running in 5 minutes!

## Prerequisites

Make sure you have installed:
- Ruby 3.2+ (`ruby -v`)
- PostgreSQL (`psql --version`)
- Redis (`redis-cli --version`)
- Bundler (`gem install bundler`)

## Step 1: Clone and Setup

```bash
# Install dependencies
bundle install

# Copy environment file
cp .env.example .env
```

## Step 2: Get Google OAuth Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project
3. Enable **Google Calendar API**
4. Go to **Credentials** → **Create Credentials** → **OAuth client ID**
5. Choose **Web application**
6. Add redirect URI: `http://localhost:3000/auth/google_oauth2/callback`
7. Copy your **Client ID** and **Client Secret**

## Step 3: Configure Environment

Edit `.env` and add your Google credentials:

```bash
GOOGLE_CLIENT_ID=your_client_id_here
GOOGLE_CLIENT_SECRET=your_client_secret_here
```

For email testing, use Mailcatcher (optional):

```bash
gem install mailcatcher
```

Your `.env` email settings for development with Mailcatcher:

```bash
SMTP_ADDRESS=localhost
SMTP_PORT=1025
```

## Step 4: Setup Database

```bash
rails db:create
rails db:migrate
```

## Step 5: Start Services

Open 3-4 terminal windows:

**Terminal 1 - Redis:**
```bash
redis-server
```

**Terminal 2 - Sidekiq:**
```bash
bundle exec sidekiq
```

**Terminal 3 - Rails:**
```bash
rails server
```

**Terminal 4 - Mailcatcher (optional):**
```bash
mailcatcher
```

Or use the helper script:
```bash
# Check what's running
bin/dev_services

# Start individual services
bin/dev_services redis     # Terminal 1
bin/dev_services sidekiq   # Terminal 2
bin/dev_services rails     # Terminal 3
```

## Step 6: Test the App

1. Visit http://localhost:3000
2. Click "Sign in with Google"
3. Authorize the app
4. Your calendar events will sync automatically
5. Check emails at http://localhost:1080 (if using Mailcatcher)

## Testing Reminders

To test the reminder system:

1. Create a calendar event in Google Calendar for 1-2 hours from now
2. Wait for the sync (happens automatically) or trigger manually in Rails console:
   ```ruby
   user = User.first
   CalendarSyncJob.perform_async(user.id)
   ```
3. Manually trigger reminder check:
   ```ruby
   CheckRemindersJob.new.perform
   ```
4. Check http://localhost:1080 for the reminder email

## Verify Everything Works

- ✅ Redis is running: `redis-cli ping` (should return PONG)
- ✅ Database is connected: `rails db:version`
- ✅ Sidekiq is processing: Visit http://localhost:3000/sidekiq
- ✅ Can authenticate: Try signing in with Google
- ✅ Events sync: Check your events on homepage
- ✅ Emails work: Check Mailcatcher at http://localhost:1080

## Common Issues

### "Connection refused" for Redis
```bash
# Start Redis
redis-server
```

### "Database does not exist"
```bash
rails db:create db:migrate
```

### OAuth error "redirect_uri_mismatch"
- Make sure your Google OAuth redirect URI is exactly: `http://localhost:3000/auth/google_oauth2/callback`
- Check for trailing slashes

### No events showing up
- Make sure you have events in your Google Calendar
- Check Sidekiq is running
- Trigger manual sync in Rails console

### Emails not sending
- Check Mailcatcher is running
- Visit http://localhost:1080
- Check Sidekiq for job errors

## Next Steps

- Read [README.md](README.md) for full documentation
- Check [DEPLOYMENT.md](DEPLOYMENT.md) for Google Marketplace publishing
- Customize reminder times in `app/models/calendar_event.rb`
- Add SMS support (future enhancement)

## Development Tips

### Rails Console
```bash
rails console

# Get first user
user = User.first

# Manually sync calendar
service = GoogleCalendarService.new(user)
service.fetch_upcoming_events

# Check upcoming events
CalendarEvent.upcoming

# Check events needing reminders
CalendarEvent.needs_reminder
```

### Monitor Background Jobs
Visit http://localhost:3000/sidekiq to see:
- Running jobs
- Queued jobs
- Failed jobs
- Scheduled jobs

### View Logs
```bash
tail -f log/development.log
```

## Questions?

- Check [README.md](README.md) for detailed documentation
- Open an issue on GitHub
- Check Sidekiq web UI for job errors

Happy coding! 🎉
