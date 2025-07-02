class DiscordNotificationJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 30.seconds, attempts: 3
  
  def perform(clan_activity_id)
    clan_activity = ClanActivity.find(clan_activity_id)
    
    # Skip if already notified
    return if clan_activity.discord_notified?
    
    # Skip if webhook not configured
    notifier = DiscordNotifier.new
    unless notifier.webhook_configured?
      Rails.logger.warn "⚠️ Discord webhook not configured, skipping notification"
      return
    end
    
    # Send notification
    if notifier.notify_clan_activity(clan_activity)
      Rails.logger.info "✅ Discord notification sent for: #{clan_activity.member_username} - #{clan_activity.message}"
    else
      Rails.logger.error "❌ Failed to send Discord notification for: #{clan_activity.member_username} - #{clan_activity.message}"
      raise "Discord notification failed"
    end
  end
end