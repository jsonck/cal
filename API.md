# API Documentation

The Calendar Reminder App includes a RESTful API built with Grape, mounted at `/api/v1`.

## Base URL

- Development: `http://localhost:3000/api/v1`
- Production: `https://yourdomain.com/api/v1`

## Authentication

Currently, the API uses simple user_id parameter authentication. For production, you should implement:
- JWT tokens
- OAuth2 bearer tokens
- API keys

## Endpoints

### Authentication

#### Check Authentication Status
```
GET /api/v1/auth/status
```

**Response:**
```json
{
  "authenticated": false,
  "message": "Please authenticate with Google"
}
```

#### Get OAuth URL
```
GET /api/v1/auth/oauth_url
```

**Response:**
```json
{
  "url": "/auth/google_oauth2"
}
```

### Users

#### Get Current User
```
GET /api/v1/users/me?user_id={user_id}
```

**Parameters:**
- `user_id` (required): Integer - The user's ID

**Success Response (200):**
```json
{
  "id": 1,
  "email": "user@example.com",
  "created_at": "2024-01-01T00:00:00.000Z"
}
```

**Error Response (404):**
```json
{
  "error": "User not found"
}
```

#### Get User's Calendar Events
```
GET /api/v1/users/events?user_id={user_id}
```

**Parameters:**
- `user_id` (required): Integer - The user's ID

**Success Response (200):**
```json
[
  {
    "id": 1,
    "summary": "Team Meeting",
    "start_time": "2024-01-15T10:00:00.000Z",
    "end_time": "2024-01-15T11:00:00.000Z",
    "reminder_sent": false
  },
  {
    "id": 2,
    "summary": "Lunch with Client",
    "start_time": "2024-01-15T12:00:00.000Z",
    "end_time": "2024-01-15T13:00:00.000Z",
    "reminder_sent": true
  }
]
```

**Notes:**
- Returns up to 20 upcoming events
- Events are ordered by start_time
- Only includes events in the future

**Error Response (404):**
```json
{
  "error": "User not found"
}
```

## OAuth Flow (Web)

The main authentication flow uses standard OAuth2:

### 1. Initiate OAuth
```
GET /auth/google_oauth2
or
POST /auth/google_oauth2
```

This redirects to Google's OAuth consent screen.

### 2. OAuth Callback
```
GET /auth/google_oauth2/callback?code={code}&state={state}
```

Google redirects here after user authorization. The app:
1. Exchanges code for access token
2. Creates/updates user record
3. Stores tokens securely
4. Triggers initial calendar sync
5. Redirects to homepage

### 3. OAuth Failure
```
GET /auth/failure?message={error_message}
```

Handles OAuth errors and redirects to homepage with error message.

### 4. Logout
```
DELETE /logout
```

Clears user session.

## Error Responses

All API endpoints return appropriate HTTP status codes:

- `200` - Success
- `400` - Bad Request (missing parameters)
- `404` - Not Found
- `500` - Internal Server Error

Error format:
```json
{
  "error": "Error message here"
}
```

## Rate Limiting

Currently not implemented. For production, consider:
- Redis-based rate limiting
- Per-user quotas
- API key tiers

## Extending the API

### Adding New Endpoints

Create new Grape API files in `app/api/v1/`:

```ruby
# app/api/v1/events.rb
module V1
  class Events < Grape::API
    namespace :events do
      desc 'Get event details'
      params do
        requires :id, type: Integer
      end
      get ':id' do
        event = CalendarEvent.find(params[:id])
        {
          id: event.id,
          summary: event.summary,
          start_time: event.start_time,
          end_time: event.end_time
        }
      end
    end
  end
end
```

Mount in `app/api/v1/base.rb`:
```ruby
module V1
  class Base < Grape::API
    version 'v1', using: :path
    format :json

    mount V1::Auth
    mount V1::Users
    mount V1::Events  # Add new endpoint
  end
end
```

### Adding Authentication

Example JWT authentication:

```ruby
# app/api/v1/base.rb
module V1
  class Base < Grape::API
    before do
      authenticate_user!
    end

    helpers do
      def authenticate_user!
        token = headers['Authorization']&.gsub('Bearer ', '')
        @current_user = User.find_by_token(token)
        error!('Unauthorized', 401) unless @current_user
      end

      def current_user
        @current_user
      end
    end

    # ... rest of API
  end
end
```

### API Versioning

To create a new API version:

1. Create `app/api/v2/` directory
2. Copy endpoints from v1
3. Make changes
4. Mount in `app/api/api.rb`:

```ruby
class API < Grape::API
  prefix 'api'

  mount V1::Base
  mount V2::Base  # New version
end
```

## Future Enhancements

Planned API features:

- [ ] JWT authentication
- [ ] Webhook support for calendar changes
- [ ] User preferences endpoints
- [ ] Reminder customization
- [ ] Bulk operations
- [ ] GraphQL support
- [ ] API documentation with Swagger
- [ ] Rate limiting
- [ ] API keys for third-party integrations

## Testing the API

### Using cURL

```bash
# Get user info
curl http://localhost:3000/api/v1/users/me?user_id=1

# Get user events
curl http://localhost:3000/api/v1/users/events?user_id=1

# Get auth status
curl http://localhost:3000/api/v1/auth/status
```

### Using HTTPie

```bash
# Install HTTPie
brew install httpie  # macOS
# or
pip install httpie

# Get user info
http GET http://localhost:3000/api/v1/users/me user_id==1

# Get user events
http GET http://localhost:3000/api/v1/users/events user_id==1
```

### Using Postman

1. Create new request
2. Set method to GET
3. URL: `http://localhost:3000/api/v1/users/me`
4. Add query parameter: `user_id` = `1`
5. Send request

## API Console (Rails)

Test the API using Rails console:

```ruby
# Start console
rails console

# Create test user
user = User.create!(
  email: 'test@example.com',
  google_id: 'test123'
)

# Create test event
event = user.calendar_events.create!(
  event_id: 'test_event_1',
  summary: 'Test Meeting',
  start_time: 2.hours.from_now,
  end_time: 3.hours.from_now
)

# Test event scopes
CalendarEvent.upcoming
CalendarEvent.needs_reminder
```

## Support

For API questions or issues:
- Check the [main README](README.md)
- Open an issue on GitHub
- Email: support@yourdomain.com
