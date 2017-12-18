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

ActiveRecord::Schema.define(version: 1001) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"
  enable_extension "citext"

  create_table "openstax_accounts_accounts", force: :cascade do |t|
    t.integer  "openstax_uid"
    t.string   "username"
    t.string   "access_token"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "full_name"
    t.string   "title"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "faculty_status",        default: 0,                   null: false
    t.string   "salesforce_contact_id"
    t.uuid     "uuid",                  default: "gen_random_uuid()", null: false
    t.integer  "role",                  default: 0,                   null: false
    t.citext   "support_identifier"
  end

  add_index "openstax_accounts_accounts", ["access_token"], name: "index_openstax_accounts_accounts_on_access_token", unique: true, using: :btree
  add_index "openstax_accounts_accounts", ["faculty_status"], name: "index_openstax_accounts_accounts_on_faculty_status", using: :btree
  add_index "openstax_accounts_accounts", ["first_name"], name: "index_openstax_accounts_accounts_on_first_name", using: :btree
  add_index "openstax_accounts_accounts", ["full_name"], name: "index_openstax_accounts_accounts_on_full_name", using: :btree
  add_index "openstax_accounts_accounts", ["last_name"], name: "index_openstax_accounts_accounts_on_last_name", using: :btree
  add_index "openstax_accounts_accounts", ["openstax_uid"], name: "index_openstax_accounts_accounts_on_openstax_uid", unique: true, using: :btree
  add_index "openstax_accounts_accounts", ["role"], name: "index_openstax_accounts_accounts_on_role", using: :btree
  add_index "openstax_accounts_accounts", ["salesforce_contact_id"], name: "index_openstax_accounts_accounts_on_salesforce_contact_id", using: :btree
  add_index "openstax_accounts_accounts", ["support_identifier"], name: "index_openstax_accounts_accounts_on_support_identifier", unique: true, using: :btree
  add_index "openstax_accounts_accounts", ["username"], name: "index_openstax_accounts_accounts_on_username", unique: true, using: :btree
  add_index "openstax_accounts_accounts", ["uuid"], name: "index_openstax_accounts_accounts_on_uuid", unique: true, using: :btree

  create_table "openstax_accounts_group_members", force: :cascade do |t|
    t.integer  "group_id",   null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "openstax_accounts_group_members", ["group_id", "user_id"], name: "index_openstax_accounts_group_members_on_group_id_and_user_id", unique: true, using: :btree
  add_index "openstax_accounts_group_members", ["user_id"], name: "index_openstax_accounts_group_members_on_user_id", using: :btree

  create_table "openstax_accounts_group_nestings", force: :cascade do |t|
    t.integer  "member_group_id",    null: false
    t.integer  "container_group_id", null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "openstax_accounts_group_nestings", ["container_group_id"], name: "index_openstax_accounts_group_nestings_on_container_group_id", using: :btree
  add_index "openstax_accounts_group_nestings", ["member_group_id"], name: "index_openstax_accounts_group_nestings_on_member_group_id", unique: true, using: :btree

  create_table "openstax_accounts_group_owners", force: :cascade do |t|
    t.integer  "group_id",   null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "openstax_accounts_group_owners", ["group_id", "user_id"], name: "index_openstax_accounts_group_owners_on_group_id_and_user_id", unique: true, using: :btree
  add_index "openstax_accounts_group_owners", ["user_id"], name: "index_openstax_accounts_group_owners_on_user_id", using: :btree

  create_table "openstax_accounts_groups", force: :cascade do |t|
    t.integer  "openstax_uid",                               null: false
    t.boolean  "is_public",                  default: false, null: false
    t.string   "name"
    t.text     "cached_subtree_group_ids"
    t.text     "cached_supertree_group_ids"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "openstax_accounts_groups", ["is_public"], name: "index_openstax_accounts_groups_on_is_public", using: :btree
  add_index "openstax_accounts_groups", ["openstax_uid"], name: "index_openstax_accounts_groups_on_openstax_uid", unique: true, using: :btree

  create_table "ownerships", force: :cascade do |t|
    t.integer  "owner_id",   null: false
    t.string   "owner_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ownerships", ["owner_id", "owner_type"], name: "index_ownerships_on_owner_id_and_owner_type", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.integer  "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "users", ["account_id"], name: "index_users_on_account_id", unique: true, using: :btree

end
