class DiscordSetting < ApplicationRecord
  KEYWORD_TYPES = %w[include exclude].freeze
  
  validates :keyword, presence: true, uniqueness: { scope: :keyword_type }
  validates :keyword_type, inclusion: { in: KEYWORD_TYPES }
  
  scope :active, -> { where(active: true) }
  scope :include_keywords, -> { where(keyword_type: 'include', active: true) }
  scope :exclude_keywords, -> { where(keyword_type: 'exclude', active: true) }
  
  def self.should_notify?(message)
    return false if message.blank?
    
    message_lower = message.downcase
    
    # Check exclude keywords first
    exclude_keywords.each do |setting|
      return false if message_lower.include?(setting.keyword.downcase)
    end
    
    # Then check include keywords
    include_keywords.any? do |setting|
      message_lower.include?(setting.keyword.downcase)
    end
  end
  
  def self.find_matching_setting(message)
    return nil if message.blank?
    
    message_lower = message.downcase
    
    include_keywords.find do |setting|
      message_lower.include?(setting.keyword.downcase)
    end
  end
  
  # Für Discord Embed-Farbe
  def discord_color
    return 0x808080 unless color_hex.present?
    
    # Konvertiere Hex zu Integer für Discord
    color_hex.gsub('#', '').to_i(16)
  end
end