# Webhook Implementation Summary

## What Was Implemented

Google Calendar webhook support has been successfully added to your Rails app. The app now receives real-time notifications when calendar events are created, updated, or deleted.

## Files Created

### Models
- `app/models/watch.rb` - Model for tracking webhook watches

### Controllers
- `app/controllers/webhooks_controller.rb` - Handles incoming webhook notifications from Google

### Jobs
- `app/jobs/setup_watch_job.rb` - Creates webhook watches for users
- `app/jobs/renew_watches_job.rb` - Automatically renews expiring watches

### Migrations
- `db/migrate/20251116145425_create_watches.rb` - Database table for watches

### Documentation
- `WEBHOOK_SETUP.md` - Detailed setup and troubleshooting guide

## Files Modified

### Models
- `app/models/user.rb` - Added `has_many :watches` association

### Services
- `app/services/google_calendar_service.rb` - Added methods:
  - `setup_watch(webhook_url)` - Create new watch
  - `stop_watch(watch)` - Stop existing watch
  - `renew_watch(old_watch, webhook_url)` - Renew expiring watch

### Controllers
- `app/controllers/sessions_controller.rb` - Triggers `SetupWatchJob` on user authentication

### Configuration
- `config/routes.rb` - Added webhook endpoint: `POST /webhooks/google_calendar`
- `config/sidekiq.yml` - Added scheduled job: `RenewWatchesJob` (daily at midnight)

### Documentation
- `README.md` - Updated features and setup instructions

## How It Works

### Initial Setup (User Login)
```
User authenticates → SetupWatchJob triggered → Watch created → Google sends notifications
```

### Real-time Updates
```
User changes event in Google Calendar
  ↓
Google sends POST to /webhooks/google_calendar
  ↓
WebhooksController receives notification
  ↓
CalendarSyncJob triggered for that user
  ↓
Events synced immediately
```

### Watch Renewal (Automated)
```
RenewWatchesJob runs daily
  ↓
Finds watches expiring in next 24 hours
  ↓
Stops old watch, creates new watch
  ↓
No user interaction required
```

## Configuration Required

Add to your `.env` file:
```bash
APP_URL=https://yourdomain.com
```

**For local development:**
1. Install ngrok: `brew install ngrok`
2. Start ngrok: `ngrok http 3000`
3. Copy HTTPS URL to `APP_URL` in `.env`

## Testing

1. **Start the app:**
   ```bash
   rails server
   bundle exec sidekiq
   ```

2. **Authenticate a user** - Watch will be created automatically

3. **Verify watch created:**
   ```ruby
   # Rails console
   User.first.watches.active
   # Should show active watch
   ```

4. **Test webhook:**
   - Edit an event in Google Calendar
   - Check Rails logs for webhook notification
   - Verify sync job triggered

## Database Migration

Already run! The `watches` table has been created with:
- `user_id` - Reference to user
- `channel_id` - Unique UUID for watch
- `resource_id` - Google's resource identifier
- `expiration` - When watch expires
- `active` - Whether watch is active

## Benefits

✅ **Real-time updates** - No more 6-hour delay
✅ **Reduced API calls** - No constant polling
✅ **Better UX** - Instant synchronization
✅ **Automatic renewal** - Zero maintenance
✅ **Fallback sync** - 6-hour polling still runs as backup

## Monitoring

### Sidekiq Dashboard
Visit `http://localhost:3000/sidekiq` to monitor:
- Webhook-triggered sync jobs
- Watch renewal job (daily)
- Any failures

### Rails Logs
Look for these messages:
- `Set up watch for user X`
- `Received webhook - Channel: ...`
- `Calendar changed for user X, triggering sync`
- `Renewing watch X for user Y`

## Troubleshooting

See `WEBHOOK_SETUP.md` for detailed troubleshooting guide.

Common issues:
- **APP_URL not set** - Watches will fail to create
- **Not HTTPS** - Google requires HTTPS for webhooks
- **Ngrok URL changed** - Restart ngrok and update APP_URL
- **Sidekiq not running** - Jobs won't process

## Next Steps

1. Set `APP_URL` environment variable
2. Restart Rails server and Sidekiq
3. Authenticate a test user
4. Verify watch created
5. Test by editing a calendar event
6. Deploy to production with public HTTPS URL

## Security Notes

- Webhook endpoint validates `channel_id` and `resource_id`
- Only valid watch records trigger syncs
- Watches tied to authenticated users
- Channel IDs are UUIDs (unguessable)
- CSRF protection properly disabled for webhook endpoint only

## Support

For questions or issues:
1. Check `WEBHOOK_SETUP.md` troubleshooting section
2. Review Rails and Sidekiq logs
3. Verify APP_URL is correct and accessible
