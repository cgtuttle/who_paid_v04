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

ActiveRecord::Schema.define(version: 20170603205749) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "account_transactions", force: :cascade do |t|
    t.integer  "account_id"
    t.decimal  "debit"
    t.decimal  "credit"
    t.string   "entry_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "journal_id"
    t.string   "journal_type"
    t.integer  "reversal_id"
    t.date     "occurred_on"
    t.integer  "source_id"
    t.string   "source_type"
  end

  add_index "account_transactions", ["account_id"], name: "index_account_transactions_on_account_id", using: :btree

  create_table "accounts", force: :cascade do |t|
    t.integer  "source_id"
    t.string   "source_type"
    t.string   "name"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "inactive",       default: false, null: false
    t.float    "default_share",  default: 1.0
    t.string   "default_method", default: "qty"
  end

  add_index "accounts", ["source_type", "source_id"], name: "index_accounts_on_source_type_and_source_id", using: :btree

  create_table "allocations", force: :cascade do |t|
    t.integer  "journal_id"
    t.string   "journal_type"
    t.integer  "account_id"
    t.string   "allocation_method"
    t.decimal  "allocation_entry"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.decimal  "allocation_factor"
  end

  add_index "allocations", ["account_id"], name: "index_allocations_on_account_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "owner_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "user_id",  null: false
    t.integer "event_id", null: false
  end

  add_index "memberships", ["user_id", "event_id"], name: "index_memberships_on_user_id_and_event_id", unique: true, using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "event_id"
    t.date     "payment_date"
    t.integer  "account_from"
    t.integer  "account_to"
    t.decimal  "amount"
    t.string   "for"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "deleted",      default: false, null: false
  end

  add_index "payments", ["event_id"], name: "index_payments_on_event_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: ""
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
    t.string   "first_name"
    t.string   "last_name"
    t.string   "user_name"
    t.string   "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.integer  "invitations_count",      default: 0
    t.integer  "role"
    t.integer  "created_by_id"
  end

  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "account_transactions", "accounts"
  add_foreign_key "allocations", "accounts"
  add_foreign_key "payments", "events"
end
