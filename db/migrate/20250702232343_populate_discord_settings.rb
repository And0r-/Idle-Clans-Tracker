class PopulateDiscordSettings < ActiveRecord::Migration[8.0]
  def up
    # Discord Include Keywords
    discord_include_keywords = [
      # Wichtige Clan-Ereignisse
      { keyword: 'has joined the clan:', emoji: '✅', color_hex: '#00FF00', description: 'Neues Mitglied beigetreten' },
      { keyword: 'left the clan:', emoji: '👋', color_hex: '#FFFF00', description: 'Mitglied hat verlassen' },
      { keyword: 'has kicked', emoji: '❌', color_hex: '#FF0000', description: 'Mitglied wurde gekickt' },
      { keyword: 'has promoted', emoji: '⬆️', color_hex: '#0099FF', description: 'Mitglied befördert' },
      { keyword: 'has demoted', emoji: '⬇️', color_hex: '#FF9900', description: 'Mitglied degradiert' },
      
      # Weitere Keywords (Clan-Verwaltung)
      { keyword: 'set the clan\'s', emoji: '⚙️', color_hex: '#9B59B6', description: 'Clan-Einstellungen geändert' },
      { keyword: 'gave vault access', emoji: '🔐', color_hex: '#3498DB', description: 'Vault-Zugriff vergeben' },
      { keyword: 'bought the upgrade', emoji: '🔧', color_hex: '#2ECC71', description: 'Clan-Upgrade gekauft' },
      { keyword: 'updated the clan\'s recruitment', emoji: '📢', color_hex: '#E74C3C', description: 'Rekrutierungs-Text geändert' },
      { keyword: 'Purchased modifier', emoji: '🐉', color_hex: '#8E44AD', description: 'Boss-Modifier gekauft' }
    ]

    discord_include_keywords.each do |attrs|
      DiscordSetting.find_or_create_by(
        keyword: attrs[:keyword],
        keyword_type: 'include'
      ) do |setting|
        setting.emoji = attrs[:emoji]
        setting.color_hex = attrs[:color_hex]
        setting.description = attrs[:description]
        setting.active = true
      end
    end

    # Discord Exclude Keywords
    discord_exclude_keywords = [
      { keyword: 'completed a quest', description: 'Quest-Abschlüsse ignorieren' },
      { keyword: 'gained experience', description: 'XP-Meldungen ignorieren' },
      { keyword: 'added', description: 'Spenden-Meldungen ignorieren' },
      { keyword: 'withdrew', description: 'Abhebungs-Meldungen ignorieren' }
    ]

    discord_exclude_keywords.each do |attrs|
      DiscordSetting.find_or_create_by(
        keyword: attrs[:keyword],
        keyword_type: 'exclude'
      ) do |setting|
        setting.description = attrs[:description]
        setting.active = true
      end
    end

    puts "✅ Discord-Keywords in Migration erstellt: #{DiscordSetting.count} Einstellungen"
  end

  def down
    DiscordSetting.destroy_all
  end
end
