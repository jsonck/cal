# SMS Reminder Setup Guide

## Overview

The app now supports SMS reminders via Twilio in addition to email reminders. Users can configure:
- **Multiple reminders per event** (up to 4)
- **Custom reminder times** (5 minutes to 24 hours before event)
- **Notification method** (email, SMS, or both)

## Features Implemented

### User Features
1. **Phone Number Management** - Add/update phone number in settings
2. **SMS Toggle** - Enable/disable SMS notifications
3. **Notification Preferences** - Choose email, SMS, or both
4. **Per-Event Reminders** - Add up to 4 reminders per event with custom times
5. **Flexible Timing** - Dropdown options: 5-60 minutes, 1-24 hours

### Technical Features
1. **EventReminder Model** - Each reminder is a separate database record
2. **TwilioService** - Handles SMS delivery
3. **Updated Jobs** - CheckRemindersJob and SendReminderJob support multiple reminders
4. **Responsive UI** - Settings page and home page with reminder management

## Twilio Setup

### 1. Create Twilio Account

1. Go to [https://www.twilio.com/](https://www.twilio.com/)
2. Sign up for a free account
3. Verify your email and phone number

### 2. Get Twilio Credentials

1. Go to [Twilio Console](https://console.twilio.com/)
2. Find your **Account SID** and **Auth Token** on the dashboard
3. Get a Twilio phone number:
   - Go to Phone Numbers → Manage → Buy a number
   - Choose a number with SMS capability
   - For free trial, you can use the trial number

### 3. Set Heroku Environment Variables

```bash
heroku config:set TWILIO_ACCOUNT_SID=your_account_sid_here
heroku config:set TWILIO_AUTH_TOKEN=your_auth_token_here
heroku config:set TWILIO_PHONE_NUMBER=+1234567890
```

Replace with your actual Twilio credentials.

## How It Works

### Reminder Flow

```
1. User authenticates → Default reminder created (60 min before, notification_method)
2. User adds custom reminders → EventReminder records created
3. CheckRemindersJob runs (every 15 min) → Finds ready-to-send reminders
4. SendReminderJob processes → Sends email/SMS based on notification_type
5. Reminder marked as sent → Won't send again
```

### Database Structure

**Users Table (updated)**
- `phone_number` - E.164 format (+1234567890)
- `sms_enabled` - Boolean flag
- `notification_method` - 'email', 'sms', or 'both'

**EventReminders Table (new)**
- `calendar_event_id` - Reference to event
- `minutes_before` - How many minutes before event (5-1440)
- `notification_type` - 'email', 'sms', or 'both'
- `sent` - Boolean, whether reminder was sent

## User Interface

### Home Page
- View all upcoming events
- See all reminders for each event
- Add new reminders with dropdowns:
  - **Time**: 5 min, 10 min, 15 min, 30 min, 1hr, 2hr, 3hr, 6hr, 12hr, 24hr
  - **Method**: Email, SMS, or Both
- Remove unsent reminders
- Maximum 4 reminders per event

### Settings Page (`/settings`)
- Add/update phone number (must include country code like +1)
- Enable/disable SMS notifications
- Set default notification method (applies to new events)

## Testing SMS Locally

### Using ngrok (for local development)

1. Start your Rails server:
   ```bash
   rails server
   ```

2. Start ngrok in another terminal:
   ```bash
   ngrok http 3000
   ```

3. Update your .env with Twilio credentials:
   ```bash
   TWILIO_ACCOUNT_SID=your_account_sid
   TWILIO_AUTH_TOKEN=your_auth_token
   TWILIO_PHONE_NUMBER=+1234567890
   ```

4. Go to settings and add your phone number

5. Create a calendar event happening in the next hour

6. Wait for the reminder job to run (or trigger manually in console):
   ```ruby
   CheckRemindersJob.new.perform
   ```

### Twilio Trial Limitations

- **Verified Numbers Only**: Free trial can only send SMS to verified phone numbers
- Add numbers at: https://console.twilio.com/us1/develop/phone-numbers/manage/verified
- **Message Prefix**: Trial messages include "Sent from your Twilio trial account"
- **Upgrade**: Remove limitations by upgrading to paid account

## Environment Variables Reference

### Required for SMS
```bash
TWILIO_ACCOUNT_SID=ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_PHONE_NUMBER=+15551234567  # Your Twilio number in E.164 format
```

### Existing Variables
```bash
APP_URL=https://textmycalendar.com
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...
REDIS_URL=...
# ... other variables
```

## Routes Added

```ruby
# Settings
GET  /settings       → settings#show
PATCH /settings      → settings#update

# Event Reminders
POST   /events/:event_id/reminders     → event_reminders#create
DELETE /events/:event_id/reminders/:id → event_reminders#destroy
```

## Notification Types

### Email Only
- Sends reminder via ReminderMailer
- No phone number required

### SMS Only
- Sends reminder via TwilioService
- Requires valid phone number and sms_enabled=true

### Both
- Sends via both email and SMS
- Falls back to email if SMS fails or no phone number

## Error Handling

### SMS Failures
- Logged but don't stop email sending
- User receives email even if SMS fails
- Check logs: `heroku logs --tail | grep Twilio`

### Common Issues

**"Cannot send SMS: user has no phone number"**
- User needs to add phone number in settings
- Phone must be in E.164 format (+1234567890)

**"Twilio error: Unable to create record"**
- Check TWILIO_* environment variables are set
- Verify Twilio phone number is SMS-enabled
- For trial accounts, verify recipient's number in Twilio console

**"Phone number must be a valid phone number"**
- Must include country code
- Valid format: +1234567890 (no spaces, dashes)
- Example: +14155551234

## Monitoring

### Check Reminder Status
```bash
heroku run rails console
```

```ruby
# See all reminders for an event
event = CalendarEvent.first
event.event_reminders

# See pending reminders
EventReminder.pending

# See reminders that should be sent
EventReminder.pending.select(&:ready_to_send?)
```

### View SMS Logs
```bash
# Heroku logs
heroku logs --tail | grep -E "(SMS|Twilio)"

# Check Twilio console
# https://console.twilio.com/us1/monitor/logs/sms
```

## Pricing

### Twilio Costs (US)
- **SMS**: ~$0.0079 per message
- **Phone Number**: ~$1.15/month
- **Free Trial**: $15.50 credit

### Estimation
- 100 events/month with 2 SMS reminders each = 200 messages
- Cost: 200 × $0.0079 = **~$1.58/month** + phone number fee

## Next Steps

1. **Set Twilio environment variables on Heroku**
2. **Test with your phone number**
3. **Consider upgrading Twilio account** for production
4. **Monitor usage** in Twilio console
5. **Add budget alerts** in Twilio to avoid overage

## Support

- Twilio docs: https://www.twilio.com/docs/sms
- Phone number formats: https://www.twilio.com/docs/glossary/what-e164
- SMS best practices: https://www.twilio.com/docs/sms/send-messages#message-best-practices
