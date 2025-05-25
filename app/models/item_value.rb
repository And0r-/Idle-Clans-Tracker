class ItemValue < ApplicationRecord
  validates :item_name, presence: true, uniqueness: true
  validates :points_per_unit, presence: true, numericality: { greater_than: 0 }
  
  scope :active, -> { where(active: true) }
  
  def self.points_for(item_name, quantity = 1)
    item = active.find_by(item_name: item_name)
    return 0 unless item
    item.points_per_unit * quantity
  end
end