class CreateItemValues < ActiveRecord::Migration[8.0]
  def change
    create_table :item_values do |t|
      t.string :item_name
      t.decimal :points_per_unit
      t.boolean :active

      t.timestamps
    end
    add_index :item_values, :item_name, unique: true
  end
end
