class Donation < ApplicationRecord
  belongs_to :member, foreign_key: :member_username, primary_key: :username
  
  enum :transaction_type, { deposit: 0, withdraw: 1 }
  
  validates :item_name, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :points_value, presence: true, numericality: true
  validates :member_username, presence: true
  
  after_save :update_member_points
  after_destroy :update_member_points
  
  private
  
  def update_member_points
    member.update_total_points!
  end
end