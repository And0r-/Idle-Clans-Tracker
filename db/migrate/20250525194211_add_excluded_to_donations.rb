class AddExcludedToDonations < ActiveRecord::Migration[8.0]
  def change
    add_column :donations, :excluded, :boolean
  end
end
