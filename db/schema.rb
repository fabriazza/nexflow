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

ActiveRecord::Schema[8.1].define(version: 2025_12_20_190619) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "consumptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "reading_date"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "utility_type_id", null: false
    t.decimal "value", precision: 10, scale: 2
    t.index ["reading_date"], name: "index_consumptions_on_reading_date"
    t.index ["user_id"], name: "index_consumptions_on_user_id"
    t.index ["utility_type_id"], name: "index_consumptions_on_utility_type_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "full_name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "utility_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "unit"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "consumptions", "users"
  add_foreign_key "consumptions", "utility_types"
end
