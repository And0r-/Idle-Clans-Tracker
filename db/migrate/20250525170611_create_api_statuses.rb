class CreateApiStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :api_statuses do |t|
      t.datetime :last_fetch_at
      t.string :status
      t.integer :logs_imported

      t.timestamps
    end
  end
end
