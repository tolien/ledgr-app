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

ActiveRecord::Schema[7.0].define(version: 2022_12_25_220630) do
  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["name", "user_id"], name: "index_categories_on_name_and_user_id", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "display_categories", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "display_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["category_id", "display_id"], name: "index_display_categories_on_category_id_and_display_id", unique: true
  end

  create_table "display_types", force: :cascade do |t|
    t.text "name"
    t.text "description"
    t.text "type"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["type"], name: "index_display_types_on_type", unique: true
  end

  create_table "displays", force: :cascade do |t|
    t.text "title"
    t.datetime "start_date", precision: nil
    t.datetime "end_date", precision: nil
    t.integer "display_type_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "position"
    t.integer "page_id"
    t.boolean "is_private", default: false
    t.integer "start_days_from_now"
  end

  create_table "entries", force: :cascade do |t|
    t.decimal "quantity", precision: 14, scale: 4
    t.datetime "datetime", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "item_id"
    t.index ["datetime"], name: "index_entries_on_datetime"
    t.index ["item_id"], name: "index_entries_on_item_id"
  end

  create_table "item_categories", force: :cascade do |t|
    t.integer "item_id", null: false
    t.integer "category_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["category_id", "item_id"], name: "index_item_categories_on_category_id_and_item_id", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.integer "entries_count", default: 0
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.integer "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.integer "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "confidential", default: true, null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "pages", force: :cascade do |t|
    t.text "title"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "position", default: 0
    t.integer "user_id"
    t.string "slug"
    t.boolean "is_private", default: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "username"
    t.string "slug"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.string "encrypted_otp_secret"
    t.string "encrypted_otp_secret_iv"
    t.string "encrypted_otp_secret_salt"
    t.integer "consumed_timestep"
    t.boolean "otp_required_for_login"
    t.boolean "is_private", default: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["slug"], name: "index_users_on_slug", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "categories", "users", name: "categories_user_id_fk", on_delete: :cascade
  add_foreign_key "display_categories", "categories", name: "display_categories_category_id_fk"
  add_foreign_key "display_categories", "displays", name: "display_categories_display_id_fk"
  add_foreign_key "displays", "display_types", name: "displays_display_type_id_fk"
  add_foreign_key "entries", "items", name: "entries_item_id_fk", on_delete: :cascade
  add_foreign_key "item_categories", "categories", name: "item_categories_category_id_fk", on_delete: :cascade
  add_foreign_key "item_categories", "items", name: "item_categories_item_id_fk", on_delete: :cascade
  add_foreign_key "items", "users", name: "items_user_id_fk", on_delete: :cascade
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id", name: "oauth_access_grants_application_id_fk"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id", name: "oauth_access_grants_resource_owner_id_fk"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id", name: "oauth_access_tokens_application_id_fk"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id", name: "oauth_access_tokens_resource_owner_id_fk"
end
