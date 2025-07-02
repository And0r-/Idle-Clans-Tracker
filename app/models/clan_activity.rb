class ClanActivity < ApplicationRecord
  validates :member_username, presence: true
  validates :message, presence: true
  validates :occurred_at, presence: true
  
  scope :unnotified, -> { where(discord_notified: false) }
  scope :recent, -> { order(occurred_at: :desc) }
  
  # Nutzt die DB-Settings!
  def self.is_relevant?(message)
    DiscordSetting.should_notify?(message)
  end
  
  # Findet passende Settings für Farbe/Emoji
  def matching_setting
    @matching_setting ||= DiscordSetting.find_matching_setting(message)
  end
  
  def discord_embed_color
    matching_setting&.discord_color || 0x808080
  end
  
  def event_emoji
    matching_setting&.emoji || '📢'
  end
  
  def mark_as_notified!
    update!(discord_notified: true)
  end
end