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

ActiveRecord::Schema.define(version: 20160301222951) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "raw_file_sources", force: :cascade do |t|
    t.string   "name",        null: false
    t.integer  "build_order", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "raw_file_sources", ["name"], name: "index_raw_file_sources_on_name", unique: true, using: :btree

  create_table "raw_files", force: :cascade do |t|
    t.integer  "raw_file_source_id",                 null: false
    t.string   "name",                               null: false
    t.datetime "upload_date",                        null: false
    t.boolean  "is_valid",           default: false
    t.string   "type",                               null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "raw_files", ["name"], name: "index_raw_files_on_name", using: :btree
  add_index "raw_files", ["raw_file_source_id"], name: "index_raw_files_on_raw_file_source_id", using: :btree
  add_index "raw_files", ["upload_date"], name: "index_raw_files_on_upload_date", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
