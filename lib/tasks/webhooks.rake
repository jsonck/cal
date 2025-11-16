namespace :webhooks do
  desc "Set up watches for all existing users"
  task backfill: :environment do
    puts "Starting webhook backfill for all users..."

    total_users = User.count
    success_count = 0
    failed_count = 0
    skipped_count = 0

    User.find_each.with_index do |user, index|
      puts "\n[#{index + 1}/#{total_users}] Processing user #{user.id} (#{user.email})..."

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
        webhook_url = "#{ENV['APP_URL']}/webhooks/google_calendar"

        result = service.setup_watch(webhook_url)

        if result
          puts "  ✅ Success - Watch created (expires: #{user.watches.last.expiration})"
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

    puts "\n" + "="*60
    puts "Webhook Backfill Complete!"
    puts "="*60
    puts "Total users:     #{total_users}"
    puts "✅ Success:      #{success_count}"
    puts "❌ Failed:       #{failed_count}"
    puts "⚠️  Skipped:      #{skipped_count}"
    puts "="*60
  end

  desc "List all active watches"
  task list: :environment do
    puts "Active Watches:"
    puts "="*80

    Watch.active.includes(:user).order(created_at: :desc).each do |watch|
      puts "User: #{watch.user.email}"
      puts "  Channel ID: #{watch.channel_id}"
      puts "  Expires: #{watch.expiration} (#{time_until(watch.expiration)})"
      puts "  Created: #{watch.created_at}"
      puts "-" * 80
    end

    total = Watch.active.count
    expiring_soon = Watch.expiring_soon.count

    puts "\nSummary:"
    puts "  Total active watches: #{total}"
    puts "  Expiring soon (< 24h): #{expiring_soon}"
  end

  desc "Clean up expired watches"
  task cleanup: :environment do
    puts "Cleaning up expired watches..."

    expired = Watch.expired
    count = expired.count

    if count > 0
      expired.each do |watch|
        puts "Deactivating expired watch for user #{watch.user.email} (expired: #{watch.expiration})"
        watch.deactivate!
      end
      puts "✅ Deactivated #{count} expired watches"
    else
      puts "✅ No expired watches found"
    end
  end

  private

  def time_until(time)
    diff = time - Time.current
    if diff < 0
      "expired #{distance_of_time((diff * -1).to_i)}"
    else
      "in #{distance_of_time(diff.to_i)}"
    end
  end

  def distance_of_time(seconds)
    days = seconds / 86400
    hours = (seconds % 86400) / 3600
    minutes = (seconds % 3600) / 60

    parts = []
    parts << "#{days}d" if days > 0
    parts << "#{hours}h" if hours > 0
    parts << "#{minutes}m" if minutes > 0

    parts.join(" ")
  end
end
