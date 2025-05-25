class Member < ApplicationRecord
  self.primary_key = :username
  
  has_many :donations, foreign_key: :member_username, dependent: :destroy
  
  validates :username, presence: true, uniqueness: true
  
  # Live-Berechnung der Gesamtpunkte
  def total_points
    donations.counted
             .where(transaction_type: 'deposit')
             .joins('LEFT JOIN item_values ON donations.item_name = item_values.item_name AND item_values.active = true')
             .sum('donations.quantity * COALESCE(item_values.points_per_unit, 0)')
  end
  
  # Für Abwärtskompatibilität - diese Methode macht jetzt nichts mehr
  def update_total_points!
    # Nichts zu tun - Punkte werden live berechnet
    true
  end
end