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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140811182553) do

  create_table "openstax_accounts_accounts", :force => true do |t|
    t.integer  "openstax_uid", :null => false
    t.string   "username",     :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "full_name"
    t.string   "title"
    t.string   "access_token"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "openstax_accounts_accounts", ["access_token"], :name => "index_openstax_accounts_accounts_on_access_token", :unique => true
  add_index "openstax_accounts_accounts", ["first_name"], :name => "index_openstax_accounts_accounts_on_first_name"
  add_index "openstax_accounts_accounts", ["full_name"], :name => "index_openstax_accounts_accounts_on_full_name"
  add_index "openstax_accounts_accounts", ["last_name"], :name => "index_openstax_accounts_accounts_on_last_name"
  add_index "openstax_accounts_accounts", ["openstax_uid"], :name => "index_openstax_accounts_accounts_on_openstax_uid", :unique => true
  add_index "openstax_accounts_accounts", ["username"], :name => "index_openstax_accounts_accounts_on_username", :unique => true

  create_table "openstax_accounts_group_members", :force => true do |t|
    t.integer  "group_id",   :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "openstax_accounts_group_members", ["group_id", "user_id"], :name => "index_openstax_accounts_group_members_on_group_id_and_user_id", :unique => true
  add_index "openstax_accounts_group_members", ["user_id"], :name => "index_openstax_accounts_group_members_on_user_id"

  create_table "openstax_accounts_group_nestings", :force => true do |t|
    t.integer  "member_group_id",    :null => false
    t.integer  "container_group_id", :null => false
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "openstax_accounts_group_nestings", ["container_group_id"], :name => "index_openstax_accounts_group_nestings_on_container_group_id"
  add_index "openstax_accounts_group_nestings", ["member_group_id"], :name => "index_openstax_accounts_group_nestings_on_member_group_id", :unique => true

  create_table "openstax_accounts_group_owners", :force => true do |t|
    t.integer  "group_id",   :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "openstax_accounts_group_owners", ["group_id", "user_id"], :name => "index_openstax_accounts_group_owners_on_group_id_and_user_id", :unique => true
  add_index "openstax_accounts_group_owners", ["user_id"], :name => "index_openstax_accounts_group_owners_on_user_id"

  create_table "openstax_accounts_groups", :force => true do |t|
    t.string   "name"
    t.boolean  "is_public",                  :null => false
    t.text     "cached_subtree_group_ids"
    t.text     "cached_supertree_group_ids"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "openstax_accounts_groups", ["is_public"], :name => "index_openstax_accounts_groups_on_is_public"

  create_table "users", :force => true do |t|
    t.integer  "openstax_accounts_account_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "users", ["openstax_accounts_account_id"], :name => "index_users_on_openstax_accounts_account_id", :unique => true

end
