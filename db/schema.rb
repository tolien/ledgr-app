# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140928230755) do

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "categories", ["name", "user_id"], name: "index_categories_on_name_and_user_id", unique: true

  create_table "display_categories", force: :cascade do |t|
    t.integer  "category_id", null: false
    t.integer  "display_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "display_categories", ["category_id", "display_id"], name: "index_display_categories_on_category_id_and_display_id", unique: true

  create_table "display_types", force: :cascade do |t|
    t.text     "name"
    t.text     "description"
    t.text     "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "displays", force: :cascade do |t|
    t.text     "title"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "display_type_id",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.integer  "page_id"
    t.integer  "start_offset_days"
    t.integer  "end_offset_days"
  end

  create_table "entries", force: :cascade do |t|
    t.decimal  "quantity"
    t.datetime "datetime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_id"
  end

  add_index "entries", ["datetime"], name: "index_entries_on_datetime"

  create_table "item_categories", force: :cascade do |t|
    t.integer  "item_id",     null: false
    t.integer  "category_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "item_categories", ["category_id", "item_id"], name: "index_item_categories_on_category_id_and_item_id", unique: true

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "entries_count"
  end

  create_table "pages", force: :cascade do |t|
    t.text     "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",   default: 0
    t.integer  "user_id"
    t.string   "slug"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "slug"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["slug"], name: "index_users_on_slug", unique: true
  add_index "users", ["username"], name: "index_users_on_username", unique: true

end