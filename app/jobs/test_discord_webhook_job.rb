class TestDiscordWebhookJob < ApplicationJob
  queue_as :default
  
  def perform
    Rails.logger.info "🧪 Sending Discord test message..."
    
    notifier = DiscordNotifier.new
    
    unless notifier.webhook_configured?
      Rails.logger.error "❌ Discord webhook not configured"
      return
    end
    
    if notifier.send_test_message
      Rails.logger.info "✅ Discord test message sent successfully"
    else
      Rails.logger.error "❌ Discord test message failed"
      raise "Discord test message failed"
    end
  end
end