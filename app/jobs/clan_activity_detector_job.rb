class ClanActivityDetectorJob < ApplicationJob
  queue_as :default
  
  def perform
    Rails.logger.info "🔍 Checking for clan activities to notify Discord..."
    
    activities_found = 0
    
    # Find unprocessed ClanLogs that might be activities
    ClanLog.unprocessed.find_each do |clan_log|
      # Check if this message is relevant for Discord notification
      if ClanActivity.is_relevant?(clan_log.message)
        begin
          # Create ClanActivity record
          clan_activity = ClanActivity.find_or_create_by(
            member_username: clan_log.member_username,
            message: clan_log.message,
            occurred_at: clan_log.timestamp
          )
          
          # Queue Discord notification if it's a new activity
          if clan_activity.persisted? && !clan_activity.discord_notified?
            DiscordNotificationJob.perform_later(clan_activity.id)
            activities_found += 1
            Rails.logger.info "📢 Found clan activity: #{clan_log.message}"
          end
          
          # Mark as processed only if ClanActivity was successfully handled
          clan_log.update!(processed: true)
        rescue => e
          Rails.logger.error "❌ Failed to create ClanActivity for log #{clan_log.id}: #{e.message}"
          # Don't mark as processed if there was an error
          # This allows retry on the next run
        end
      else
        # Mark as processed if not relevant
        clan_log.update!(processed: true)
      end
    end
    
    Rails.logger.info "✅ Found #{activities_found} new clan activities for Discord"
  end
end