# Google Calendar Reminder App - Project Summary

## Overview

A Rails application that integrates with Google Calendar via OAuth2 to automatically send email reminders 1 hour before calendar events. Built with a RESTful API using Grape, background job processing with Sidekiq, and ready for deployment to Google Workspace Marketplace.

## Key Features

1. **Google OAuth Integration**
   - Secure OAuth2 authentication
   - Calendar.readonly scope (non-invasive)
   - Token refresh handling
   - OmniAuth integration

2. **Calendar Synchronization**
   - Automatic sync every 6 hours
   - Manual sync on user authentication
   - Handles upcoming events (30 days)
   - Event deduplication

3. **Email Reminders**
   - Automated reminders 1 hour before events
   - Background job processing
   - HTML and plain text email templates
   - SMTP configuration for various providers

4. **RESTful API**
   - Built with Grape framework
   - Versioned API (v1)
   - User and event endpoints
   - Easy to extend

5. **Background Jobs**
   - Sidekiq for job processing
   - Scheduled tasks (Sidekiq Scheduler)
   - Calendar sync jobs
   - Reminder check jobs

## Technology Stack

### Backend
- **Ruby 3.2+**
- **Rails 7.2+** - Web framework
- **PostgreSQL** - Database
- **Redis** - Cache and job queue
- **Sidekiq** - Background job processing
- **Sidekiq Scheduler** - Cron-like scheduling

### API & Integration
- **Grape** - API framework
- **Grape Entity** - API serialization
- **Google API Client** - Google Calendar integration
- **OmniAuth Google OAuth2** - Authentication

### Frontend
- **Turbo Rails** - SPA-like interactions
- **Stimulus** - JavaScript framework
- **Importmap** - JavaScript module management

## Project Structure

```
cal/
├── app/
│   ├── api/                    # Grape API
│   │   ├── api.rb             # API root
│   │   └── v1/                # API version 1
│   │       ├── base.rb        # API base
│   │       ├── auth.rb        # Auth endpoints
│   │       └── users.rb       # User endpoints
│   ├── controllers/           # Rails controllers
│   │   ├── application_controller.rb
│   │   ├── home_controller.rb
│   │   └── sessions_controller.rb
│   ├── jobs/                  # Background jobs
│   │   ├── calendar_sync_job.rb
│   │   ├── check_reminders_job.rb
│   │   ├── send_reminder_job.rb
│   │   └── sync_all_calendars_job.rb
│   ├── mailers/               # Email mailers
│   │   └── reminder_mailer.rb
│   ├── models/                # ActiveRecord models
│   │   ├── user.rb
│   │   └── calendar_event.rb
│   ├── services/              # Business logic
│   │   └── google_calendar_service.rb
│   └── views/
│       ├── home/
│       │   └── index.html.erb
│       └── reminder_mailer/
│           ├── event_reminder.html.erb
│           └── event_reminder.text.erb
├── config/
│   ├── initializers/
│   │   ├── omniauth.rb        # OAuth configuration
│   │   └── sidekiq.rb         # Sidekiq configuration
│   ├── routes.rb              # Application routes
│   └── sidekiq.yml            # Sidekiq schedule
├── db/
│   └── migrate/               # Database migrations
├── bin/
│   ├── setup_app              # Setup script
│   └── dev_services           # Development helper
├── .env.example               # Environment template
├── Procfile                   # Heroku deployment
├── README.md                  # Main documentation
├── QUICKSTART.md              # Quick setup guide
├── DEPLOYMENT.md              # Google Marketplace guide
├── API.md                     # API documentation
└── PROJECT_SUMMARY.md         # This file
```

## Database Schema

### Users Table
- `id` - Primary key
- `email` - User email (unique)
- `google_id` - Google user ID (unique)
- `access_token` - OAuth access token
- `refresh_token` - OAuth refresh token
- `token_expires_at` - Token expiration
- `created_at`, `updated_at` - Timestamps

### Calendar Events Table
- `id` - Primary key
- `user_id` - Foreign key to users
- `event_id` - Google Calendar event ID (unique per user)
- `summary` - Event title
- `start_time` - Event start
- `end_time` - Event end
- `reminder_sent` - Boolean flag
- `created_at`, `updated_at` - Timestamps

### Indexes
- `users.email` (unique)
- `users.google_id` (unique)
- `calendar_events.user_id`
- `calendar_events.[user_id, event_id]` (unique)
- `calendar_events.start_time`

## API Endpoints

### Authentication
- `GET /api/v1/auth/status` - Check auth status
- `GET /api/v1/auth/oauth_url` - Get OAuth URL
- `GET/POST /auth/google_oauth2` - Initiate OAuth
- `GET /auth/google_oauth2/callback` - OAuth callback
- `DELETE /logout` - Sign out

### Users
- `GET /api/v1/users/me?user_id={id}` - Get user info
- `GET /api/v1/users/events?user_id={id}` - Get user events

### Admin
- `GET /sidekiq` - Sidekiq web UI

## Background Jobs & Scheduling

### Jobs
1. **CalendarSyncJob** - Syncs individual user calendar
2. **SyncAllCalendarsJob** - Syncs all users (every 6 hours)
3. **CheckRemindersJob** - Checks for events needing reminders (every 15 minutes)
4. **SendReminderJob** - Sends individual reminder emails

### Schedule
```yaml
check_reminders:
  cron: '*/15 * * * *'  # Every 15 minutes

sync_all_calendars:
  cron: '0 */6 * * *'    # Every 6 hours
```

## User Flow

1. User visits homepage
2. Clicks "Sign in with Google"
3. Redirected to Google OAuth consent
4. Grants calendar.readonly permission
5. Redirected back to app
6. App creates/updates user record
7. App stores OAuth tokens
8. Triggers initial calendar sync
9. Background job fetches upcoming events
10. Scheduler checks for events 1 hour away
11. Sends email reminders via Sidekiq
12. User receives email notification

## Security Considerations

- OAuth tokens encrypted in database
- HTTPS enforced in production
- CSRF protection enabled
- Session cookies secure and httponly
- Environment variables for secrets
- Read-only calendar access
- No sensitive data logged

## Configuration Files

### Environment Variables (.env)
- `GOOGLE_CLIENT_ID` - OAuth client ID
- `GOOGLE_CLIENT_SECRET` - OAuth secret
- `REDIS_URL` - Redis connection
- `SMTP_*` - Email settings
- `DATABASE_URL` - Database connection

### Important Config Files
- `config/initializers/omniauth.rb` - OAuth setup
- `config/initializers/sidekiq.rb` - Job processor
- `config/sidekiq.yml` - Job schedule
- `config/routes.rb` - URL routing
- `config/database.yml` - Database config

## Development Workflow

1. **Setup**: Run `bin/setup_app` or follow QUICKSTART.md
2. **Start Services**:
   - Redis: `redis-server`
   - Sidekiq: `bundle exec sidekiq`
   - Rails: `rails server`
   - Mailcatcher: `mailcatcher` (optional)
3. **Monitor**:
   - Logs: `tail -f log/development.log`
   - Jobs: http://localhost:3000/sidekiq
   - Emails: http://localhost:1080
4. **Test**: Visit http://localhost:3000

## Deployment Options

### Heroku
```bash
heroku create
heroku addons:create heroku-postgresql:mini
heroku addons:create heroku-redis:mini
git push heroku main
```

### Railway
- Connect GitHub repo
- Add PostgreSQL plugin
- Add Redis plugin
- Configure environment variables

### AWS/GCP/Azure
- Deploy with Docker
- Use managed PostgreSQL
- Use managed Redis
- Configure load balancer
- Set up SSL/TLS

## Google Marketplace Readiness

### Required Components
- ✅ OAuth2 integration
- ✅ Calendar.readonly scope
- ✅ Production-ready code
- ✅ Email functionality
- ✅ Background processing
- ⏳ Privacy policy page
- ⏳ Terms of service page
- ⏳ Support page
- ⏳ App icons/screenshots
- ⏳ OAuth verification

### Steps to Publish
See [DEPLOYMENT.md](DEPLOYMENT.md) for complete guide.

## Testing Strategy

### Manual Testing
1. OAuth flow works
2. Calendar sync accurate
3. Reminders sent on time
4. Email delivery works
5. UI responsive
6. Error handling

### Automated Testing (Future)
- RSpec for models/services
- Request specs for API
- Feature specs for user flows
- Job specs for Sidekiq
- Integration tests

## Performance Considerations

### Optimizations
- Database indexes on foreign keys
- Event deduplication
- Token refresh on demand
- Background job processing
- Redis caching (future)

### Scalability
- Sidekiq horizontal scaling
- Database read replicas
- Redis clustering
- CDN for assets
- Load balancing

## Future Enhancements

### High Priority
- [ ] SMS reminders (Twilio)
- [ ] Customizable reminder times
- [ ] User preferences dashboard
- [ ] Multiple calendars support

### Medium Priority
- [ ] Web push notifications
- [ ] Recurring reminder rules
- [ ] Timezone improvements
- [ ] Event categories/filtering

### Low Priority
- [ ] Mobile app (React Native)
- [ ] Desktop notifications
- [ ] Calendar write permissions
- [ ] Event creation from app
- [ ] Team/shared calendars

## Common Tasks

### Add New Background Job
1. Create job in `app/jobs/`
2. Add schedule to `config/sidekiq.yml`
3. Test with `JobName.perform_async`

### Add New API Endpoint
1. Create file in `app/api/v1/`
2. Mount in `app/api/v1/base.rb`
3. Document in `API.md`

### Update Email Template
1. Edit `app/views/reminder_mailer/`
2. Update both HTML and text versions
3. Test with Mailcatcher

### Change Reminder Time
Edit `app/models/calendar_event.rb`:
```ruby
scope :needs_reminder, -> {
  where(reminder_sent: false)
    .where("start_time BETWEEN ? AND ?",
           2.hours.from_now,  # Change this
           3.hours.from_now)  # And this
}
```

## Monitoring & Logging

### What to Monitor
- Background job failures
- Email delivery rate
- OAuth token refresh errors
- API response times
- Database performance

### Recommended Tools
- Sentry - Error tracking
- New Relic - APM
- Papertrail - Logging
- Sidekiq Pro - Job monitoring
- Google Analytics - Usage

## Support & Documentation

- **README.md** - Main documentation
- **QUICKSTART.md** - Quick setup
- **DEPLOYMENT.md** - Publishing guide
- **API.md** - API reference
- **This file** - Project overview

## Contributors

Built for easy deployment to Google Workspace Marketplace, ready for public use.

## License

MIT License - Free for commercial and personal use.

---

**Last Updated**: November 2024
**Version**: 1.0.0
**Status**: Ready for deployment
