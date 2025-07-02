class CreateDiscordSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :discord_settings do |t|
      t.string :keyword, null: false
      t.string :keyword_type, null: false # 'include' oder 'exclude'
      t.boolean :active, default: true
      t.string :emoji
      t.string :color_hex
      t.text :description

      t.timestamps
    end
    
    add_index :discord_settings, [:keyword_type, :active]
    add_index :discord_settings, [:keyword, :keyword_type], unique: true
  end
end
