class CreateDonations < ActiveRecord::Migration[8.0]
  def change
    create_table :donations do |t|
      t.references :member, null: false, foreign_key: true
      t.integer :transaction_type
      t.string :item_name
      t.integer :quantity
      t.decimal :points_value
      t.text :raw_message
      t.datetime :occurred_at

      t.timestamps
    end
  end
end
