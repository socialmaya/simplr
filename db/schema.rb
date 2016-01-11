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

ActiveRecord::Schema.define(version: 20160111011958) do

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.integer  "comment_id"
    t.text     "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "anon_token"
    t.string   "image"
  end

  create_table "connections", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "other_user_id"
    t.integer  "group_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.boolean  "invite"
    t.boolean  "request"
    t.string   "anon_token"
    t.string   "unique_token"
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.text     "body"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "anon_token"
    t.string   "image"
    t.integer  "user_id"
    t.string   "unique_token"
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "receiver_id"
    t.integer  "group_id"
    t.text     "body"
    t.string   "image"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "anon_token"
    t.string   "receiver_token"
  end

  create_table "notes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "sender_id"
    t.string   "message"
    t.string   "action"
    t.boolean  "seen"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "anon_token"
    t.string   "sender_token"
    t.integer  "item_id"
  end

  create_table "posts", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "body"
    t.string   "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "anon_token"
    t.integer  "group_id"
  end

  create_table "tags", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.integer  "group_id"
    t.integer  "comment_id"
    t.string   "tag"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "anon_token"
    t.integer  "index"
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "auth_token"
    t.string   "image"
    t.text     "bio"
    t.string   "email"
    t.string   "password"
    t.string   "password_salt"
    t.string   "unique_token"
  end

end
