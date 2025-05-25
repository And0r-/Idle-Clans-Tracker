class CreateClanLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :clan_logs do |t|
      t.string :clan_name
      t.string :member_username
      t.text :message
      t.datetime :timestamp

      t.timestamps
    end
  end
end
