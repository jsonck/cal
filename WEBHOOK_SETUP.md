# Google Calendar Webhook Setup Guide

This app now supports real-time calendar updates via Google Calendar webhooks (Push Notifications API).

## What Changed

Previously, the app polled Google Calendar every 6 hours to check for changes. Now it receives instant notifications when calendar events are created, updated, or deleted.

## Benefits

- **Real-time updates**: Changes appear immediately instead of waiting up to 6 hours
- **Reduced API usage**: No constant polling needed
- **Better user experience**: Reminders stay accurate even for last-minute changes

## Configuration Required

### 1. Set Your App URL

Add this environment variable to your `.env` file:

```bash
APP_URL=https://yourdomain.com
```

**Important**:
- Must be a publicly accessible HTTPS URL
- Google Calendar webhooks require HTTPS (HTTP won't work)
- For local development, use a service like [ngrok](https://ngrok.com/) to expose your local server

#### Local Development with ngrok

```bash
# Install ngrok
brew install ngrok  # or download from ngrok.com

# Start your Rails server
rails server

# In another terminal, start ngrok
ngrok http 3000

# Copy the HTTPS URL (e.g., https://abc123.ngrok.io)
# Add to .env:
APP_URL=https://abc123.ngrok.io
```

### 2. Google Cloud Console Setup

Your webhook endpoint is automatically configured at:
```
POST https://yourdomain.com/webhooks/google_calendar
```

**No additional Google Cloud Console configuration needed!** The Google Calendar API automatically allows webhook notifications when you have the Calendar API enabled.

### 3. Verify Domain Ownership (Production Only)

For production deployments, Google may require domain verification:

1. Go to [Google Search Console](https://search.google.com/search-console)
2. Add and verify your domain
3. This proves you own the domain receiving webhooks

## How It Works

### When a User Authenticates

1. User logs in with Google OAuth
2. App sets up a "watch" on their primary calendar
3. Google sends notifications to `/webhooks/google_calendar` when events change
4. App triggers an immediate calendar sync for that user

### Watch Lifecycle

- **Initial Setup**: Watch created when user authenticates
- **Expiration**: Watches expire after ~7 days (Google's default)
- **Renewal**: Automated daily job checks for expiring watches and renews them
- **No User Action**: Renewals happen automatically in the background

### Scheduled Jobs

The app now has three scheduled jobs:

1. **Check Reminders** (every 15 minutes)
   - Checks for events starting in 1 hour
   - Sends reminder emails

2. **Sync All Calendars** (every 6 hours)
   - Backup sync in case webhooks fail
   - Ensures data consistency

3. **Renew Watches** (daily at midnight)
   - Finds watches expiring in next 24 hours
   - Creates new watches before old ones expire
   - Deactivates expired watches

## Testing Webhooks

### 1. Check Watch Status

After a user authenticates, verify the watch was created:

```ruby
# Rails console
user = User.first
user.watches.active
# Should show an active watch with future expiration
```

### 2. Trigger a Test Notification

1. Authenticate a user
2. Open Google Calendar in another tab
3. Create/edit/delete an event
4. Check your Rails logs - you should see:
   ```
   Received webhook - Channel: [uuid], State: exists, Resource: [id]
   Calendar changed for user [id], triggering sync
   ```

### 3. Monitor Sidekiq

Visit `http://localhost:3000/sidekiq` to see:
- Webhook notifications triggering `CalendarSyncJob`
- Scheduled `RenewWatchesJob` running daily
- Any failures or errors

## Troubleshooting

### Webhooks Not Received

1. **Check APP_URL is set correctly**
   ```bash
   echo $APP_URL
   # Should show your public HTTPS URL
   ```

2. **Verify endpoint is accessible**
   ```bash
   curl -X POST https://yourdomain.com/webhooks/google_calendar \
     -H "X-Goog-Channel-ID: test" \
     -H "X-Goog-Resource-State: exists"

   # Should return 404 (watch not found) but confirms endpoint works
   ```

3. **Check Rails logs**
   ```bash
   tail -f log/development.log
   # Look for "Received webhook" messages
   ```

### Watch Creation Fails

1. **Verify user has valid OAuth tokens**
   ```ruby
   user = User.first
   user.access_token.present?  # Should be true
   user.token_expired?         # Should be false
   ```

2. **Check Sidekiq is running**
   ```bash
   ps aux | grep sidekiq
   # Should show sidekiq process
   ```

3. **Check SetupWatchJob logs**
   - Look for errors in Sidekiq web UI
   - Common issue: APP_URL not set or not HTTPS

### Watch Expires Before Renewal

If watches expire:
1. The daily `RenewWatchesJob` will deactivate them
2. The 6-hour `SyncAllCalendarsJob` continues as backup
3. User's next login creates a new watch
4. No data loss - just slower updates until renewed

## Production Deployment Checklist

- [ ] Set `APP_URL` environment variable to production domain
- [ ] Ensure domain uses HTTPS (required by Google)
- [ ] Verify domain ownership in Google Search Console
- [ ] Test webhook endpoint is publicly accessible
- [ ] Confirm Sidekiq worker is running
- [ ] Monitor first few webhook notifications in logs
- [ ] Check `RenewWatchesJob` runs successfully

## Database Schema

### watches table

| Column | Type | Description |
|--------|------|-------------|
| user_id | integer | Reference to user |
| channel_id | string | Unique UUID for this watch |
| resource_id | string | Google's internal resource identifier |
| expiration | datetime | When this watch expires |
| active | boolean | Whether watch is currently active |

## API Endpoints Added

### Webhook Endpoint
- `POST /webhooks/google_calendar` - Receives Google Calendar notifications

**Headers sent by Google:**
- `X-Goog-Channel-ID` - The channel UUID
- `X-Goog-Resource-State` - Event type (sync, exists, not_exists)
- `X-Goog-Resource-ID` - Resource identifier

## Background Jobs Added

### SetupWatchJob
- **Trigger**: User authentication
- **Purpose**: Create new webhook watch
- **Actions**: Deactivates old watches, creates new watch

### RenewWatchesJob
- **Schedule**: Daily at midnight
- **Purpose**: Renew expiring watches
- **Actions**: Finds watches expiring in 24h, renews them

## Security Considerations

- CSRF protection disabled for webhook endpoint (Google doesn't send CSRF tokens)
- Channel IDs are UUIDs (hard to guess)
- Only valid watch records trigger syncs
- Watches belong to authenticated users
- Webhook endpoint validates channel_id and resource_id

## Further Reading

- [Google Calendar Push Notifications](https://developers.google.com/calendar/api/guides/push)
- [Watch Resources](https://developers.google.com/calendar/api/v3/reference/events/watch)
- [Sidekiq Scheduler](https://github.com/sidekiq-scheduler/sidekiq-scheduler)
