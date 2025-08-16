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

ActiveRecord::Schema[7.2].define(version: 2025_08_14_065201) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "locations", force: :cascade do |t|
    t.decimal "latitude", precision: 9, scale: 6, null: false
    t.decimal "longitude", precision: 9, scale: 6, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["latitude", "longitude"], name: "index_locations_on_latitude_and_longitude"
    t.check_constraint "latitude >= '-90'::integer::numeric AND latitude <= 90::numeric", name: "chk_loc_lat"
    t.check_constraint "longitude >= '-180'::integer::numeric AND longitude <= 180::numeric", name: "chk_loc_lng"
  end

  create_table "post_tags", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id", "tag_id"], name: "index_post_tags_on_post_id_and_tag_id", unique: true
    t.index ["post_id"], name: "index_post_tags_on_post_id"
    t.index ["tag_id"], name: "index_post_tags_on_tag_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "location_id"
    t.string "title", null: false
    t.text "body", null: false
    t.datetime "event_datetime", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_datetime"], name: "index_posts_on_event_datetime"
    t.index ["location_id"], name: "index_posts_on_location_id"
    t.index ["user_id", "created_at"], name: "index_posts_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "user_identities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.string "email"
    t.string "display_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "uid"], name: "index_user_identities_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_user_identities_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "weather_observations", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.decimal "temperature_c", precision: 5, scale: 2
    t.integer "humidity_pct"
    t.decimal "pressure_hpa", precision: 6, scale: 1
    t.datetime "observed_at"
    t.jsonb "snapshot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["observed_at"], name: "index_weather_observations_on_observed_at"
    t.index ["post_id"], name: "index_weather_observations_on_post_id", unique: true
    t.index ["snapshot"], name: "index_weather_observations_on_snapshot", using: :gin
    t.check_constraint "humidity_pct IS NULL OR humidity_pct >= 0 AND humidity_pct <= 100", name: "chk_wx_hum"
    t.check_constraint "pressure_hpa IS NULL OR pressure_hpa >= 800::numeric AND pressure_hpa <= 1100::numeric", name: "chk_wx_pres"
    t.check_constraint "snapshot IS NULL OR observed_at IS NOT NULL", name: "chk_wx_has_observed_at"
    t.check_constraint "temperature_c IS NULL OR temperature_c >= '-90'::integer::numeric AND temperature_c <= 60::numeric", name: "chk_wx_temp"
  end

  add_foreign_key "post_tags", "posts"
  add_foreign_key "post_tags", "tags"
  add_foreign_key "posts", "locations"
  add_foreign_key "posts", "users"
  add_foreign_key "user_identities", "users"
  add_foreign_key "weather_observations", "posts"
end
