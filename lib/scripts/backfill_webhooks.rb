# Backfill webhooks for all existing users
# Run this in rails console: load 'lib/scripts/backfill_webhooks.rb'
# Or run directly: heroku run rails runner lib/scripts/backfill_webhooks.rb

puts "Starting webhook backfill for all users..."
puts "APP_URL: #{ENV['APP_URL']}"
puts ""

webhook_url = "#{ENV['APP_URL']}/webhooks/google_calendar"
total_users = User.count
success_count = 0
failed_count = 0
skipped_count = 0

User.find_each.with_index do |user, index|
  puts "[#{index + 1}/#{total_users}] Processing user #{user.id} (#{user.email})..."

  # Check if user has valid tokens
  unless user.access_token.present?
    puts "  ⚠️  Skipped - No access token"
    skipped_count += 1
    next
  end

  # Check if user already has an active watch
  if user.watches.active.exists?
    puts "  ⚠️  Skipped - Already has active watch"
    skipped_count += 1
    next
  end

  # Set up watch
  begin
    service = GoogleCalendarService.new(user)
    result = service.setup_watch(webhook_url)

    if result
      watch = user.watches.last
      puts "  ✅ Success - Watch created (expires: #{watch.expiration})"
      success_count += 1
    else
      puts "  ❌ Failed - Could not create watch"
      failed_count += 1
    end
  rescue => e
    puts "  ❌ Error - #{e.message}"
    failed_count += 1
  end

  # Small delay to avoid rate limiting
  sleep 0.5
end

puts ""
puts "="*60
puts "Webhook Backfill Complete!"
puts "="*60
puts "Total users:     #{total_users}"
puts "✅ Success:      #{success_count}"
puts "❌ Failed:       #{failed_count}"
puts "⚠️  Skipped:      #{skipped_count}"
puts "="*60
