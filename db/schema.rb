# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_02_232343) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "api_statuses", force: :cascade do |t|
    t.datetime "last_fetch_at"
    t.string "status"
    t.integer "logs_imported"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "clan_activities", force: :cascade do |t|
    t.string "member_username", null: false
    t.text "message", null: false
    t.datetime "occurred_at", null: false
    t.boolean "discord_notified", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["discord_notified"], name: "index_clan_activities_on_discord_notified"
    t.index ["member_username", "message", "occurred_at"], name: "idx_clan_activities_unique", unique: true
    t.index ["occurred_at"], name: "index_clan_activities_on_occurred_at"
  end

  create_table "clan_logs", force: :cascade do |t|
    t.string "clan_name"
    t.string "member_username"
    t.text "message"
    t.datetime "timestamp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "processed"
  end

  create_table "discord_settings", force: :cascade do |t|
    t.string "keyword", null: false
    t.string "keyword_type", null: false
    t.boolean "active", default: true
    t.string "emoji"
    t.string "color_hex"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["keyword", "keyword_type"], name: "index_discord_settings_on_keyword_and_keyword_type", unique: true
    t.index ["keyword_type", "active"], name: "index_discord_settings_on_keyword_type_and_active"
  end

  create_table "donations", force: :cascade do |t|
    t.integer "transaction_type"
    t.string "item_name"
    t.integer "quantity"
    t.text "raw_message"
    t.datetime "occurred_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "member_username", null: false
    t.boolean "excluded"
  end

  create_table "item_values", force: :cascade do |t|
    t.string "item_name"
    t.decimal "points_per_unit"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_name"], name: "index_item_values_on_item_name", unique: true
  end

  create_table "members", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["username"], name: "index_members_on_username", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "donations", "members", column: "member_username", primary_key: "username"
end
