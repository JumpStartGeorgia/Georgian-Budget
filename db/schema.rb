# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161103110636) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "name_translations", force: :cascade do |t|
    t.integer  "name_id",    null: false
    t.string   "locale",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "text"
    t.index ["locale"], name: "index_name_translations_on_locale", using: :btree
    t.index ["name_id"], name: "index_name_translations_on_name_id", using: :btree
  end

  create_table "names", force: :cascade do |t|
    t.date     "start_date"
    t.string   "nameable_type"
    t.integer  "nameable_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "is_most_recent", default: false, null: false
    t.index ["nameable_type", "nameable_id"], name: "index_names_on_nameable_type_and_nameable_id", using: :btree
    t.index ["start_date"], name: "index_names_on_start_date", using: :btree
  end

  create_table "page_content_translations", force: :cascade do |t|
    t.integer  "page_content_id", null: false
    t.string   "locale",          null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "title"
    t.text     "content"
    t.index ["locale"], name: "index_page_content_translations_on_locale", using: :btree
    t.index ["page_content_id"], name: "index_page_content_translations_on_page_content_id", using: :btree
  end

  create_table "page_contents", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "planned_finances", force: :cascade do |t|
    t.decimal  "amount",                  precision: 14, scale: 2
    t.date     "start_date"
    t.date     "end_date"
    t.string   "finance_plannable_type"
    t.integer  "finance_plannable_id"
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.date     "announce_date"
    t.boolean  "most_recently_announced",                          default: false, null: false
    t.string   "time_period_type"
    t.index ["end_date"], name: "index_planned_finances_on_end_date", using: :btree
    t.index ["finance_plannable_type", "finance_plannable_id"], name: "index_planned_finances_on_finance_plannable", using: :btree
    t.index ["start_date"], name: "index_planned_finances_on_start_date", using: :btree
    t.index ["time_period_type"], name: "index_planned_finances_on_time_period_type", using: :btree
  end

  create_table "possible_duplicate_pairs", force: :cascade do |t|
    t.integer "item1_id"
    t.integer "item2_id"
    t.string  "pair_type"
    t.index ["item1_id"], name: "index_item1", using: :btree
    t.index ["item2_id"], name: "index_item2", using: :btree
  end

  create_table "priorities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "code"
  end

  create_table "programs", force: :cascade do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "code"
    t.integer  "priority_id"
    t.index ["priority_id"], name: "index_programs_on_priority_id", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spending_agencies", force: :cascade do |t|
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "code"
    t.integer  "priority_id"
    t.index ["priority_id"], name: "index_spending_agencies_on_priority_id", using: :btree
  end

  create_table "spent_finances", force: :cascade do |t|
    t.decimal  "amount",                 precision: 14, scale: 2
    t.date     "start_date"
    t.date     "end_date"
    t.string   "finance_spendable_type"
    t.integer  "finance_spendable_id"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "time_period_type"
    t.index ["end_date"], name: "index_spent_finances_on_end_date", using: :btree
    t.index ["finance_spendable_type", "finance_spendable_id"], name: "index_spent_finances_on_finance_spendable", using: :btree
    t.index ["start_date"], name: "index_spent_finances_on_start_date", using: :btree
    t.index ["time_period_type"], name: "index_spent_finances_on_time_period_type", using: :btree
  end

  create_table "totals", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role_id"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["role_id"], name: "index_users_on_role_id", using: :btree
  end

  add_foreign_key "programs", "priorities"
  add_foreign_key "spending_agencies", "priorities"
end
