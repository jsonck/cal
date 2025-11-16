# Google Calendar Webhook Flow

## Visual Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    USER AUTHENTICATION FLOW                      │
└─────────────────────────────────────────────────────────────────┘

User clicks "Sign in with Google"
            ↓
Google OAuth2 authentication
            ↓
SessionsController#create
            ↓
    ┌───────────────┴───────────────┐
    ↓                               ↓
CalendarSyncJob          SetupWatchJob
(sync events)            (create webhook)
    ↓                               ↓
Events saved            Watch record created
to database             in database
                                   ↓
                        Google Calendar API
                        creates webhook watch
                                   ↓
                        Google sends "sync"
                        notification (confirmation)


┌─────────────────────────────────────────────────────────────────┐
│                   REAL-TIME UPDATE FLOW                          │
└─────────────────────────────────────────────────────────────────┘

User edits event in Google Calendar
            ↓
Google Calendar detects change
            ↓
Google sends POST request to:
/webhooks/google_calendar
            ↓
WebhooksController#google_calendar
            ↓
Validates channel_id & resource_id
            ↓
Finds Watch record in database
            ↓
Triggers CalendarSyncJob(user_id)
            ↓
GoogleCalendarService fetches events
            ↓
Events updated in database
            ↓
User sees updated events immediately


┌─────────────────────────────────────────────────────────────────┐
│                    WATCH RENEWAL FLOW                            │
└─────────────────────────────────────────────────────────────────┘

RenewWatchesJob runs daily at midnight
            ↓
Finds watches expiring in next 24 hours
            ↓
For each expiring watch:
    ↓
GoogleCalendarService#renew_watch
    ↓
    ┌─────────┴──────────┐
    ↓                    ↓
Stop old watch      Create new watch
    ↓                    ↓
Old watch          New watch record
deactivated        saved to database
    ↓                    ↓
    └────────┬───────────┘
            ↓
Watch renewed successfully
(user never notified)


┌─────────────────────────────────────────────────────────────────┐
│                    BACKUP SYNC FLOW                              │
└─────────────────────────────────────────────────────────────────┘

SyncAllCalendarsJob runs every 6 hours
            ↓
For each user in database:
    ↓
CalendarSyncJob(user_id)
    ↓
Events synced
    ↓
Ensures consistency even if
webhooks fail or expire
```

## Request/Response Details

### Webhook Notification Headers

When Google sends a webhook notification, it includes these headers:

```
X-Goog-Channel-ID: 550e8400-e29b-41d4-a716-446655440000
X-Goog-Resource-State: exists
X-Goog-Resource-ID: def123abc456
X-Goog-Channel-Token: (optional, if set)
X-Goog-Resource-URI: https://www.googleapis.com/calendar/v3/calendars/primary/events
X-Goog-Message-Number: 1
```

### Resource States

- `sync` - Initial notification when watch is created (ignore)
- `exists` - Resource changed (trigger sync)
- `not_exists` - Resource deleted (rare for events)

### Watch Lifecycle

```
Day 0: Watch created (expiration set to ~7 days)
Day 1-6: Receives webhook notifications
Day 6: RenewWatchesJob finds it (< 24 hours to expiry)
Day 6: New watch created, old watch stopped
Day 7: Old watch would have expired (already replaced)
Day 8-13: New watch active
...continues indefinitely
```

## Database Schema Flow

```
┌──────────────┐
│    users     │
├──────────────┤
│ id           │
│ email        │
│ google_id    │
│ access_token │
│ refresh_token│
└──────┬───────┘
       │ has_many
       │
       ├─────────────────────┬─────────────────────┐
       │                     │                     │
       ↓                     ↓                     ↓
┌──────────────┐      ┌──────────────┐    ┌──────────────┐
│   watches    │      │calendar_events│    │              │
├──────────────┤      ├──────────────┤    │              │
│ id           │      │ id           │    │              │
│ user_id      │      │ user_id      │    │              │
│ channel_id   │      │ event_id     │    │              │
│ resource_id  │      │ summary      │    │              │
│ expiration   │      │ start_time   │    │              │
│ active       │      │ end_time     │    │              │
└──────────────┘      │ reminder_sent│    │              │
                      └──────────────┘    │              │
```

## Error Handling

### Watch Creation Fails
```
SetupWatchJob executes
    ↓
Error occurs (network, auth, etc.)
    ↓
Job fails, error logged
    ↓
User still functional (6-hour sync as backup)
    ↓
User's next login retries watch setup
```

### Webhook Not Received
```
Event changes in Google Calendar
    ↓
Webhook fails to send (network issue)
    ↓
App doesn't receive notification
    ↓
Event remains out of sync temporarily
    ↓
SyncAllCalendarsJob runs (within 6 hours)
    ↓
Event synced via polling backup
```

### Watch Expires Before Renewal
```
RenewWatchesJob fails or misses a watch
    ↓
Watch expires (7 days)
    ↓
Next RenewWatchesJob deactivates it
    ↓
User falls back to 6-hour polling
    ↓
User's next login creates new watch
    ↓
Real-time updates resume
```

## Performance Benefits

### Before Webhooks
```
Every 6 hours:
- Fetch events for ALL users
- Parse and update ALL events
- Even if nothing changed

API Calls per day: 4 × number_of_users
Data transfer: High (all events every time)
Update latency: 0-6 hours
```

### With Webhooks
```
Only when events change:
- Webhook notification received
- Fetch events for THAT user only
- Update only changed events

API Calls per day: ~1-5 per user (only when they edit)
Data transfer: Low (only when needed)
Update latency: Real-time (<1 second)
Backup sync: Still runs every 6 hours
```

## Security Flow

```
POST /webhooks/google_calendar
            ↓
CSRF check skipped (webhooks don't have tokens)
            ↓
Extract channel_id from headers
            ↓
Look up Watch in database
            ↓
Watch found?
    ↓ No → Return 404 (invalid/unknown channel)
    ↓ Yes
            ↓
Validate resource_id matches
            ↓
Match?
    ↓ No → Return 404 (tampered request)
    ↓ Yes
            ↓
Watch belongs to valid User?
    ↓ Yes
            ↓
Trigger sync for that user only
            ↓
Return 200 OK
```

This ensures:
- Only registered watches trigger syncs
- Channel IDs are UUIDs (unguessable)
- Each watch tied to authenticated user
- No syncing of arbitrary users
