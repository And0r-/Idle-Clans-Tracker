class Donation < ApplicationRecord
  belongs_to :member, foreign_key: :member_username, primary_key: :username
  
  enum :transaction_type, { deposit: 0, withdraw: 1 }
  
  validates :item_name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :member_username, presence: true
  
  # Scope für nicht-ausgeschlossene Donations
  scope :counted, -> { where(excluded: [false, nil]) }
  scope :excluded, -> { where(excluded: true) }
  
  # Live-Berechnung der Punkte
  def calculated_points
    return 0 if excluded?
    ItemValue.points_for(item_name, quantity)
  end
  
  # Alias für Backward-Compatibility in Views
  alias_method :points_value, :calculated_points
end