class CreateMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :members do |t|
      t.string :username
      t.decimal :total_points

      t.timestamps
    end
    add_index :members, :username, unique: true
  end
end
