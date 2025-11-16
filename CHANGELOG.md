# Changelog

All notable changes to the Google Calendar Reminder App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-14

### Initial Release

#### Added
- Google OAuth2 integration with Calendar.readonly scope
- User authentication and session management
- Calendar synchronization service
- Automatic email reminders 1 hour before events
- RESTful API built with Grape
  - User endpoints
  - Authentication endpoints
  - Event listing endpoints
- Background job processing with Sidekiq
  - CalendarSyncJob - Individual user sync
  - SyncAllCalendarsJob - All users sync (every 6 hours)
  - CheckRemindersJob - Check for upcoming events (every 15 minutes)
  - SendReminderJob - Send individual reminders
- Email mailer with HTML and text templates
- Web UI for OAuth flow and event display
- Sidekiq web interface for job monitoring
- PostgreSQL database with optimized indexes
- Redis integration for job queue
- Comprehensive documentation:
  - README.md - Main documentation
  - QUICKSTART.md - Setup guide
  - DEPLOYMENT.md - Google Marketplace guide
  - API.md - API documentation
  - PROJECT_SUMMARY.md - Technical overview
- Environment configuration with .env support
- Development helper scripts
- Heroku deployment ready (Procfile)
- Security features:
  - CSRF protection
  - Secure session cookies
  - HTTPS enforcement in production
  - Environment variable secrets

#### Database Schema
- Users table with OAuth token storage
- CalendarEvents table with reminder tracking
- Optimized indexes for performance

#### Configuration
- OmniAuth Google OAuth2 setup
- Sidekiq scheduler configuration
- SMTP email configuration
- Production-ready environment settings

---

## [Unreleased]

### Planned Features
- SMS reminders via Twilio integration
- Customizable reminder times
- User preferences dashboard
- Multiple calendar support
- Web push notifications
- JWT authentication for API
- Rate limiting for API endpoints
- Privacy policy page
- Terms of service page
- Support page
- Automated testing suite (RSpec)
- Docker deployment option
- Admin dashboard

---

## Version History

### Version Naming Convention
- **Major.Minor.Patch**
- Major: Breaking changes
- Minor: New features, backwards compatible
- Patch: Bug fixes, minor improvements

### Release Schedule
- Major releases: As needed
- Minor releases: Monthly (when features ready)
- Patch releases: As needed for critical bugs

---

## How to Update

### From Source
```bash
git pull origin main
bundle install
rails db:migrate
rails assets:precompile
rails server
```

### Heroku
```bash
git push heroku main
heroku run rails db:migrate
heroku restart
```

---

## Breaking Changes

None yet (initial release)

---

## Security Updates

Will be documented here as they occur.

---

## Deprecation Notices

None yet (initial release)

---

## Support

For issues related to updates:
- Check GitHub issues
- Review documentation
- Contact support@yourdomain.com

---

**Note**: This changelog will be updated with each release. Subscribe to releases on GitHub to get notifications.
