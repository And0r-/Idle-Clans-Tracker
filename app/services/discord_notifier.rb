class DiscordNotifier
  include HTTParty
  
  def initialize
    @webhook_url = ENV['DISCORD_WEBHOOK_URL']
  end
  
  def notify_clan_activity(clan_activity)
    return false unless webhook_configured?
    
    payload = build_activity_payload(clan_activity)
    
    response = HTTParty.post(@webhook_url, {
      body: payload.to_json,
      headers: { 'Content-Type' => 'application/json' },
      timeout: 10
    })
    
    if response.success?
      Rails.logger.info "✅ Discord notification sent for: #{clan_activity.message}"
      clan_activity.mark_as_notified!
      true
    else
      Rails.logger.error "❌ Discord notification failed: #{response.code} - #{response.body}"
      false
    end
  rescue => e
    Rails.logger.error "❌ Discord notification error: #{e.message}"
    false
  end
  
  def send_test_message
    return false unless webhook_configured?
    
    payload = build_test_payload
    
    response = HTTParty.post(@webhook_url, {
      body: payload.to_json,
      headers: { 'Content-Type' => 'application/json' },
      timeout: 10
    })
    
    if response.success?
      Rails.logger.info "✅ Discord test message sent"
      true
    else
      Rails.logger.error "❌ Discord test message failed: #{response.code} - #{response.body}"
      false
    end
  rescue => e
    Rails.logger.error "❌ Discord test message error: #{e.message}"
    false
  end
  
  def webhook_configured?
    @webhook_url.present?
  end
  
  private
  
  def build_activity_payload(clan_activity)
    emoji = clan_activity.event_emoji
    color = clan_activity.discord_embed_color
    
    # Zeitstempel in Zürich-Zeit formatieren
    zurich_time = clan_activity.occurred_at.in_time_zone('Europe/Zurich')
    
    {
      embeds: [{
        title: "#{emoji} Clan-Aktivität",
        description: clan_activity.message,
        color: color,
        timestamp: clan_activity.occurred_at.iso8601,
        fields: [
          {
            name: "Mitglied",
            value: clan_activity.member_username,
            inline: true
          },
          {
            name: "Zeit",
            value: zurich_time.strftime('%d.%m.%Y %H:%M'),
            inline: true
          }
        ],
        footer: {
          text: "Idle Clans Tracker"
        }
      }]
    }
  end
  
  def build_test_payload
    zurich_time = Time.current.in_time_zone('Europe/Zurich')
    
    {
      embeds: [{
        title: "🧪 Test-Nachricht",
        description: "Discord-Integration funktioniert! Dies ist eine Test-Nachricht vom Idle Clans Tracker.",
        color: 0x00FF00,
        timestamp: Time.current.iso8601,
        fields: [
          {
            name: "Status",
            value: "✅ Verbindung OK",
            inline: true
          },
          {
            name: "Zeit",
            value: zurich_time.strftime('%d.%m.%Y %H:%M'),
            inline: true
          },
          {
            name: "Webhook-URL",
            value: webhook_configured? ? "✅ Konfiguriert" : "❌ Fehlt",
            inline: true
          }
        ],
        footer: {
          text: "Test von Idle Clans Tracker"
        }
      }]
    }
  end
end