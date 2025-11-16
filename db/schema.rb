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

ActiveRecord::Schema[7.2].define(version: 2025_11_16_145425) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "calendar_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "event_id"
    t.string "summary"
    t.datetime "start_time"
    t.datetime "end_time"
    t.boolean "reminder_sent", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["start_time"], name: "index_calendar_events_on_start_time"
    t.index ["user_id", "event_id"], name: "index_calendar_events_on_user_id_and_event_id", unique: true
    t.index ["user_id"], name: "index_calendar_events_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "google_id"
    t.text "access_token"
    t.text "refresh_token"
    t.datetime "token_expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_id"], name: "index_users_on_google_id", unique: true
  end

  create_table "watches", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "channel_id", null: false
    t.string "resource_id", null: false
    t.datetime "expiration", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_watches_on_channel_id", unique: true
    t.index ["expiration"], name: "index_watches_on_expiration"
    t.index ["user_id", "active"], name: "index_watches_on_user_id_and_active"
    t.index ["user_id"], name: "index_watches_on_user_id"
  end

  add_foreign_key "calendar_events", "users"
  add_foreign_key "watches", "users"
end
