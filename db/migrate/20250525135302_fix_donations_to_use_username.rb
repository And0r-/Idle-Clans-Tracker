class FixDonationsToUseUsername < ActiveRecord::Migration[8.0]
  def change
    # member_id entfernen
    remove_foreign_key :donations, :members
    remove_column :donations, :member_id
    
    # member_username hinzufügen
    add_column :donations, :member_username, :string, null: false
    add_foreign_key :donations, :members, column: :member_username, primary_key: :username
  end
end