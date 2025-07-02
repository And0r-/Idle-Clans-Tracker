class CreateClanActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :clan_activities do |t|
      t.string :member_username, null: false
      t.text :message, null: false
      t.datetime :occurred_at, null: false
      t.boolean :discord_notified, default: false

      t.timestamps
    end
    
    add_index :clan_activities, :discord_notified
    add_index :clan_activities, :occurred_at
    add_index :clan_activities, [:member_username, :message, :occurred_at], unique: true, name: 'idx_clan_activities_unique'
  end
end
