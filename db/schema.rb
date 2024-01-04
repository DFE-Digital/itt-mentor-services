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

ActiveRecord::Schema[7.1].define(version: 2024_01_08_151908) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "service", ["claims", "placements"]

  create_table "flipflop_features", force: :cascade do |t|
    t.string "key", null: false
    t.boolean "enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "organisation_type", null: false
    t.uuid "organisation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_type", "organisation_id"], name: "index_memberships_on_organisation"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "provider_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "placements", default: false
    t.index ["placements"], name: "index_providers_on_placements"
    t.index ["provider_code"], name: "index_providers_on_provider_code", unique: true
  end

  create_table "schools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "urn", null: false
    t.boolean "placements", default: false
    t.boolean "claims", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "postcode"
    t.string "town"
    t.string "ukprn"
    t.string "telephone"
    t.string "website"
    t.string "address1"
    t.string "address2"
    t.string "address3"
    t.string "group"
    t.string "type_of_establishment"
    t.string "phase"
    t.string "gender"
    t.integer "minimum_age"
    t.integer "maximum_age"
    t.string "religious_character"
    t.string "admissions_policy"
    t.string "urban_or_rural"
    t.integer "school_capacity"
    t.integer "total_pupils"
    t.integer "total_girls"
    t.integer "total_boys"
    t.integer "percentage_free_school_meals"
    t.string "special_classes"
    t.string "send_provision"
    t.string "training_with_disabilities"
    t.string "rating"
    t.date "last_inspection_date"
    t.string "email_address"
    t.index ["claims"], name: "index_schools_on_claims"
    t.index ["placements"], name: "index_schools_on_placements"
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "support_user", default: false
    t.enum "service", null: false, enum_type: "service"
    t.index ["service", "email"], name: "index_users_on_service_and_email", unique: true
  end

  add_foreign_key "memberships", "users"
end
