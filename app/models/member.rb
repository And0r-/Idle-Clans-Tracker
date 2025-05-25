class Member < ApplicationRecord
  # Username als Primary Key definieren
  self.primary_key = :username
  
  has_many :donations, foreign_key: :member_username, dependent: :destroy
  
  validates :username, presence: true, uniqueness: true
  validates :total_points, numericality: { greater_than_or_equal_to: 0 }
  
  def update_total_points!
    self.total_points = donations.where(transaction_type: 'deposit').sum(:points_value)
    save!
  end
end