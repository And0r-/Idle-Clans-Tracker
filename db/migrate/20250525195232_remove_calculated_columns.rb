class RemoveCalculatedColumns < ActiveRecord::Migration[8.0]
  def change
    remove_column :donations, :points_value, :decimal
    remove_column :members, :total_points, :decimal
  end
end