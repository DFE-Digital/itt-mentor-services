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

ActiveRecord::Schema[7.1].define(version: 2024_03_25_095831) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "claim_status", ["internal", "draft", "submitted"]
  create_enum "mentor_training_type", ["refresher", "initial"]
  create_enum "placement_status", ["draft", "published"]
  create_enum "provider_type", ["scitt", "lead_school", "university"]
  create_enum "service", ["claims", "placements"]
  create_enum "subject_area", ["primary", "secondary"]

  create_table "audits", force: :cascade do |t|
    t.uuid "auditable_id"
    t.string "auditable_type"
    t.uuid "associated_id"
    t.string "associated_type"
    t.uuid "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "claims", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "provider_id"
    t.string "reference"
    t.datetime "submitted_at"
    t.string "created_by_type"
    t.uuid "created_by_id"
    t.enum "status", enum_type: "claim_status"
    t.string "submitted_by_type"
    t.uuid "submitted_by_id"
    t.index ["created_by_type", "created_by_id"], name: "index_claims_on_created_by"
    t.index ["provider_id"], name: "index_claims_on_provider_id"
    t.index ["reference"], name: "index_claims_on_reference", unique: true
    t.index ["school_id"], name: "index_claims_on_school_id"
    t.index ["submitted_by_type", "submitted_by_id"], name: "index_claims_on_submitted_by"
  end

  create_table "flipflop_features", force: :cascade do |t|
    t.string "key", null: false
    t.boolean "enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "good_job_batches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.jsonb "serialized_properties"
    t.text "on_finish"
    t.text "on_success"
    t.text "on_discard"
    t.text "callback_queue_name"
    t.integer "callback_priority"
    t.datetime "enqueued_at"
    t.datetime "discarded_at"
    t.datetime "finished_at"
  end

  create_table "good_job_executions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id", null: false
    t.text "job_class"
    t.text "queue_name"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.text "error"
    t.integer "error_event", limit: 2
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
  end

  create_table "good_job_settings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "key"
    t.jsonb "value"
    t.index ["key"], name: "index_good_job_settings_on_key", unique: true
  end

  create_table "good_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "queue_name"
    t.integer "priority"
    t.jsonb "serialized_params"
    t.datetime "scheduled_at"
    t.datetime "performed_at"
    t.datetime "finished_at"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "active_job_id"
    t.text "concurrency_key"
    t.text "cron_key"
    t.uuid "retried_good_job_id"
    t.datetime "cron_at"
    t.uuid "batch_id"
    t.uuid "batch_callback_id"
    t.boolean "is_discrete"
    t.integer "executions_count"
    t.text "job_class"
    t.integer "error_event", limit: 2
    t.text "labels", array: true
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "mentor_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type", null: false
    t.uuid "mentor_id", null: false
    t.uuid "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mentor_id"], name: "index_mentor_memberships_on_mentor_id"
    t.index ["school_id"], name: "index_mentor_memberships_on_school_id"
    t.index ["type", "mentor_id"], name: "index_mentor_memberships_on_type_and_mentor_id"
    t.index ["type", "school_id", "mentor_id"], name: "index_mentor_memberships_on_type_and_school_id_and_mentor_id", unique: true
  end

  create_table "mentor_trainings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.enum "training_type", enum_type: "mentor_training_type"
    t.integer "hours_completed"
    t.datetime "date_completed"
    t.uuid "claim_id"
    t.uuid "mentor_id"
    t.uuid "provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_id"], name: "index_mentor_trainings_on_claim_id"
    t.index ["mentor_id"], name: "index_mentor_trainings_on_mentor_id"
    t.index ["provider_id"], name: "index_mentor_trainings_on_provider_id"
  end

  create_table "mentors", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "trn", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["trn"], name: "index_mentors_on_trn", unique: true
  end

  create_table "pg_search_documents", force: :cascade do |t|
    t.text "content"
    t.text "organisation_type"
    t.string "searchable_type"
    t.uuid "searchable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["searchable_type", "searchable_id"], name: "index_pg_search_documents_on_searchable"
  end

  create_table "placement_mentor_joins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "mentor_id", null: false
    t.uuid "placement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mentor_id"], name: "index_placement_mentor_joins_on_mentor_id"
    t.index ["placement_id"], name: "index_placement_mentor_joins_on_placement_id"
  end

  create_table "placement_subject_joins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "subject_id", null: false
    t.uuid "placement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["placement_id"], name: "index_placement_subject_joins_on_placement_id"
    t.index ["subject_id"], name: "index_placement_subject_joins_on_subject_id"
  end

  create_table "placements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.enum "status", default: "draft", enum_type: "placement_status"
    t.date "start_date"
    t.date "end_date"
    t.uuid "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_placements_on_school_id"
  end

  create_table "providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "placements_service", default: false
    t.enum "provider_type", null: false, enum_type: "provider_type"
    t.string "name", null: false
    t.string "ukprn"
    t.string "urn"
    t.string "email_address"
    t.string "telephone"
    t.string "website"
    t.string "address1"
    t.string "address2"
    t.string "address3"
    t.string "town"
    t.string "city"
    t.string "county"
    t.string "postcode"
    t.boolean "accredited", default: false
    t.index ["code"], name: "index_providers_on_code", unique: true
    t.index ["placements_service"], name: "index_providers_on_placements_service"
  end

  create_table "regions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.integer "claims_funding_available_per_hour_pence", default: 0, null: false
    t.string "claims_funding_available_per_hour_currency", default: "GBP", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_regions_on_name", unique: true
  end

  create_table "schools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "urn", null: false
    t.boolean "placements_service", default: false
    t.boolean "claims_service", default: false
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
    t.string "district_admin_name"
    t.string "district_admin_code"
    t.uuid "region_id"
    t.uuid "trust_id"
    t.float "longitude"
    t.float "latitude"
    t.string "local_authority_name"
    t.string "local_authority_code"
    t.index ["claims_service"], name: "index_schools_on_claims_service"
    t.index ["latitude"], name: "index_schools_on_latitude"
    t.index ["longitude"], name: "index_schools_on_longitude"
    t.index ["placements_service"], name: "index_schools_on_placements_service"
    t.index ["region_id"], name: "index_schools_on_region_id"
    t.index ["trust_id"], name: "index_schools_on_trust_id"
    t.index ["urn"], name: "index_schools_on_urn", unique: true
  end

  create_table "subjects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.enum "subject_area", enum_type: "subject_area"
    t.string "name", null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trusts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "uid", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_trusts_on_uid", unique: true
  end

  create_table "user_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.string "organisation_type", null: false
    t.uuid "organisation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_type", "organisation_id"], name: "index_memberships_on_organisation"
    t.index ["user_id", "organisation_id"], name: "index_user_memberships_on_user_id_and_organisation_id", unique: true
    t.index ["user_id"], name: "index_user_memberships_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.string "dfe_sign_in_uid"
    t.datetime "last_signed_in_at"
    t.datetime "discarded_at"
    t.index ["type", "discarded_at", "email"], name: "index_users_on_type_and_discarded_at_and_email"
    t.index ["type", "email"], name: "index_users_on_type_and_email", unique: true
  end

  add_foreign_key "claims", "providers"
  add_foreign_key "claims", "schools"
  add_foreign_key "mentor_memberships", "mentors"
  add_foreign_key "mentor_memberships", "schools"
  add_foreign_key "mentor_trainings", "claims"
  add_foreign_key "mentor_trainings", "mentors"
  add_foreign_key "mentor_trainings", "providers"
  add_foreign_key "placement_mentor_joins", "mentors"
  add_foreign_key "placement_mentor_joins", "placements"
  add_foreign_key "placement_subject_joins", "placements"
  add_foreign_key "placement_subject_joins", "subjects"
  add_foreign_key "placements", "schools"
  add_foreign_key "schools", "regions"
  add_foreign_key "schools", "trusts"
  add_foreign_key "user_memberships", "users"
end
