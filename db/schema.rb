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

ActiveRecord::Schema[8.0].define(version: 2025_03_23_071558) do
  create_table "banned_users", force: :cascade do |t|
    t.string "line_user_id", null: false
    t.datetime "banned_at", null: false
    t.string "reason", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["line_user_id"], name: "index_banned_users_on_line_user_id", unique: true
  end

  create_table "user_logs", force: :cascade do |t|
    t.string "line_user_id", null: false
    t.datetime "last_request_at", null: false
    t.integer "warning_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["last_request_at"], name: "index_user_logs_on_last_request_at"
    t.index ["line_user_id"], name: "index_user_logs_on_line_user_id"
  end
end
