# Google Marketplace Deployment Guide

This guide walks you through publishing the Calendar Reminder App to the Google Workspace Marketplace.

## Prerequisites

- Google Cloud Platform account
- Domain ownership verification
- App deployed to production server
- SSL certificate (HTTPS required)

## Step 1: Google Cloud Console Setup

### 1.1 Create/Select Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Note your Project ID



### 1.2 Enable Required APIs
Enable these APIs in your project:
- Google Calendar API
- Google Workspace Marketplace SDK

```bash
gcloud services enable calendar-json.googleapis.com
gcloud services enable admin.googleapis.com
```

### 1.3 Configure OAuth Consent Screen

1. Go to **APIs & Services > OAuth consent screen**
2. Select **External** user type (or Internal if G Suite organization)
3. Fill in application information:
   - **App name**: Calendar Event Reminder
   - **User support email**: your-support-email@domain.com
   - **App logo**: Upload 120x120 PNG logo
   - **App domain**:
     - Homepage: https://yourdomain.com
     - Privacy policy: https://yourdomain.com/privacy
     - Terms of service: https://yourdomain.com/terms
   - **Authorized domains**: Add your domain
   - **Developer contact**: your-email@domain.com

4. **Scopes**: Add required scopes
   - `https://www.googleapis.com/auth/calendar.readonly`
   - `email`
   - `profile`
   - `openid`

5. **Test users** (during development):
   - Add email addresses of users who can test

### 1.4 Create OAuth 2.0 Credentials

1. Go to **APIs & Services > Credentials**
2. Click **Create Credentials > OAuth client ID**
3. Application type: **Web application**
4. Name: "Calendar Reminder App"
5. **Authorized redirect URIs**:
   - `https://yourdomain.com/auth/google_oauth2/callback`
   - Add development URLs if needed
6. Click **Create** and save:

## Step 2: Create Required Pages

Create these pages on your website:

### Privacy Policy (`/privacy`)
Must include:
- What data you collect (email, calendar events)
- How you use the data (send reminders)
- How data is stored and protected
- User rights (deletion, access)
- Contact information

### Terms of Service (`/terms`)
Must include:
- Service description
- User responsibilities
- Limitation of liability
- Service modifications
- Termination policy

### Support Page (`/support`)
- How to get help
- FAQs
- Contact information

## Step 3: Prepare App Listing

### 3.1 Required Assets

Create these assets:

1. **App Icon** (128x128 PNG)
   - Clear, professional icon
   - No transparency
   - Represents calendar/reminders

2. **Screenshots** (1280x800 or 640x400 PNG)
   - At least 1 screenshot
   - Show main functionality
   - Recommended: 3-5 screenshots

3. **Marketing Assets**
   - Banner image (optional)
   - Promotional images

### 3.2 App Description

Write compelling description (example):

```
Calendar Event Reminder - Never miss an important event!

Automatically receive email reminders 1 hour before your Google Calendar events.

FEATURES:
• Automatic email notifications 1 hour before events
• Read-only access to your calendar (secure)
• Set it and forget it - runs automatically
• Clean, simple interface
• No ads, no tracking

HOW IT WORKS:
1. Connect your Google Calendar (read-only)
2. Events are synced automatically
3. Receive email reminders 1 hour before each event
4. That's it!

PRIVACY:
• Only requests read-only calendar access
• Your data is never shared
• See our privacy policy for details

SUPPORT:
Email: support@yourdomain.com
Website: https://yourdomain.com/support
```

## Step 4: Google Workspace Marketplace Configuration

### 4.1 Enable Marketplace SDK

1. Go to **APIs & Services > Google Workspace Marketplace SDK**
2. Click **Configuration**

### 4.2 Configure App

**Application Information:**
- Application name: Calendar Event Reminder
- Short description: (140 chars) "Get email reminders 1 hour before Google Calendar events"
- Long description: (Use prepared description from 3.2)
- Category: Productivity
- Support URLs:
  - Terms of Service: https://yourdomain.com/terms
  - Privacy Policy: https://yourdomain.com/privacy

**OAuth Scopes:**
Add:
- `https://www.googleapis.com/auth/calendar.readonly`

**Extensions:**
- Select extension type: None (for web app)
- Or select appropriate extension if needed

**Store Listing:**
- Upload icon (128x128)
- Upload screenshots
- Add video URL (optional but recommended)

**Regions:**
- Select target regions/countries

## Step 5: Testing

### 5.1 Test Installation

1. In Marketplace SDK, use "Test Installation" feature
2. Install app as test user
3. Verify:
   - OAuth flow works
   - Scopes are requested correctly
   - Calendar sync works
   - Reminders are sent
   - UI is functional

### 5.2 Test Checklist

- [ ] OAuth authentication completes successfully
- [ ] Calendar events sync correctly
- [ ] Email reminders are sent
- [ ] Privacy policy is accessible
- [ ] Terms of service is accessible
- [ ] Support page is accessible
- [ ] App works on different browsers
- [ ] Mobile responsive design

## Step 6: Verification Process

### 6.1 Submit for Verification

If requesting sensitive or restricted scopes:

1. Complete OAuth verification questionnaire
2. Provide:
   - Domain verification
   - Privacy policy URL
   - YouTube demo video (showing OAuth flow)
   - Justification for scopes

### 6.2 Verification Timeline

- Review typically takes 3-5 business days
- May request additional information
- Follow up if no response after 7 days

## Step 7: Publishing

### 7.1 Submit for Review

1. Complete all required fields
2. Click "Submit for Review"
3. Google reviews for:
   - Policy compliance
   - User experience
   - Security
   - Brand guidelines

### 7.2 Review Timeline

- Initial review: 3-5 business days
- Re-submissions: 1-3 business days

### 7.3 Post-Approval

Once approved:
- App goes live on Marketplace
- Users can discover and install
- Monitor user feedback
- Respond to reviews

## Step 8: Post-Launch

### 8.1 Monitoring

Set up monitoring for:
- Error tracking (Sentry, Rollbar, etc.)
- Performance monitoring
- User analytics
- Email delivery rates

### 8.2 User Support

- Monitor support email
- Respond to user reviews
- Update documentation
- Fix reported bugs

### 8.3 Updates

When updating your app:
- Test thoroughly
- Update version number
- If changing scopes, re-submit for review
- Notify users of major changes

## Common Issues

### OAuth Verification Failed
- Ensure privacy policy is accessible
- Verify all URLs are HTTPS
- Check domain ownership
- Provide clear scope justification

### Rejected Submission
- Review Google's policies
- Address specific feedback
- Improve screenshots/description
- Re-submit with changes

### Scope Approval Delayed
- Provide detailed video demo
- Explain why each scope is needed
- Show security measures
- Follow up after 7 days

## Resources

- [Google Workspace Marketplace Documentation](https://developers.google.com/workspace/marketplace)
- [OAuth Verification Process](https://support.google.com/cloud/answer/9110914)
- [Branding Guidelines](https://developers.google.com/workspace/marketplace/branding-guidelines)
- [Review Process](https://developers.google.com/workspace/marketplace/review-process)

## Checklist Before Submission

- [ ] App deployed to production with HTTPS
- [ ] Google OAuth credentials configured
- [ ] Privacy policy published and accessible
- [ ] Terms of service published and accessible
- [ ] Support page published
- [ ] App icon created (128x128)
- [ ] Screenshots created (at least 1)
- [ ] App description written
- [ ] OAuth consent screen configured
- [ ] Scopes properly requested
- [ ] App tested with real users
- [ ] Error monitoring configured
- [ ] Email delivery tested
- [ ] Mobile responsive
- [ ] All marketplace fields completed

## Support

For issues with this deployment guide or the application:
- Email: your-support@domain.com
- Documentation: https://github.com/your-repo

Good luck with your Google Marketplace launch!
