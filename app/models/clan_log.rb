class ClanLog < ApplicationRecord
  validates :clan_name, presence: true
  validates :member_username, presence: true
  validates :message, presence: true
  validates :timestamp, presence: true
  
  # Unique constraint für Duplikat-Vermeidung
  validates :timestamp, uniqueness: { scope: [:member_username, :message] }
  
  scope :recent, -> { order(timestamp: :desc) }
  scope :unprocessed, -> { where(processed: false) }
end