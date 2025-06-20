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

ActiveRecord::Schema[8.0].define(version: 2025_06_17_154722) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_trgm"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "appetite", ["actively_looking", "interested", "not_open", "already_organised"]
  create_enum "claim_status", ["internal_draft", "draft", "submitted", "payment_in_progress", "payment_information_requested", "payment_information_sent", "paid", "payment_not_approved", "sampling_in_progress", "sampling_provider_not_approved", "sampling_not_approved", "clawback_requested", "clawback_in_progress", "clawback_complete"]
  create_enum "mentor_training_type", ["refresher", "initial"]
  create_enum "placement_status", ["draft", "published"]
  create_enum "placement_year_group", ["nursery", "reception", "year_1", "year_2", "year_3", "year_4", "year_5", "year_6", "mixed_year_groups"]
  create_enum "provider_type", ["scitt", "lead_school", "university"]
  create_enum "service", ["claims", "placements"]
  create_enum "subject_area", ["primary", "secondary"]

  create_table "academic_years", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.date "starts_on"
    t.date "ends_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.uuid "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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

  create_table "claim_activities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action"
    t.uuid "user_id", null: false
    t.string "record_type", null: false
    t.uuid "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_claim_activities_on_record"
    t.index ["user_id"], name: "index_claim_activities_on_user_id"
  end

  create_table "claim_windows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academic_year_id", null: false
    t.date "starts_on", null: false
    t.date "ends_on", null: false
    t.date "discarded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_year_id"], name: "index_claim_windows_on_academic_year_id"
    t.index ["discarded_at"], name: "index_claim_windows_on_discarded_at"
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
    t.boolean "reviewed", default: false
    t.uuid "claim_window_id"
    t.text "sampling_reason"
    t.datetime "payment_in_progress_at"
    t.text "unpaid_reason"
    t.string "zendesk_url"
    t.uuid "support_user_id"
    t.index ["claim_window_id"], name: "index_claims_on_claim_window_id"
    t.index ["created_by_type", "created_by_id"], name: "index_claims_on_created_by"
    t.index ["provider_id"], name: "index_claims_on_provider_id"
    t.index ["reference"], name: "index_claims_on_reference"
    t.index ["school_id"], name: "index_claims_on_school_id"
    t.index ["submitted_by_type", "submitted_by_id"], name: "index_claims_on_submitted_by"
    t.index ["support_user_id"], name: "index_claims_on_support_user_id"
  end

  create_table "clawback_claims", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "claim_id", null: false
    t.uuid "clawback_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_id"], name: "index_clawback_claims_on_claim_id"
    t.index ["clawback_id"], name: "index_clawback_claims_on_clawback_id"
  end

  create_table "clawbacks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "downloaded_at"
  end

  create_table "download_access_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "activity_record_type", null: false
    t.uuid "activity_record_id", null: false
    t.string "email_address", null: false
    t.datetime "downloaded_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_record_type", "activity_record_id"], name: "index_download_access_tokens_on_activity_record"
  end

  create_table "eligibilities", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "claim_window_id", null: false
    t.uuid "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_window_id"], name: "index_eligibilities_on_claim_window_id"
    t.index ["school_id"], name: "index_eligibilities_on_school_id"
  end

  create_table "flipper_features", force: :cascade do |t|
    t.string "key", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_flipper_features_on_key", unique: true
  end

  create_table "flipper_gates", force: :cascade do |t|
    t.string "feature_key", null: false
    t.string "key", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["feature_key", "key", "value"], name: "index_flipper_gates_on_feature_key_and_key_and_value", unique: true
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
    t.datetime "jobs_finished_at"
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
    t.text "error_backtrace", array: true
    t.uuid "process_id"
    t.interval "duration"
    t.index ["active_job_id", "created_at"], name: "index_good_job_executions_on_active_job_id_and_created_at"
    t.index ["process_id", "created_at"], name: "index_good_job_executions_on_process_id_and_created_at"
  end

  create_table "good_job_processes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "state"
    t.integer "lock_type", limit: 2
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
    t.uuid "locked_by_id"
    t.datetime "locked_at"
    t.index ["active_job_id", "created_at"], name: "index_good_jobs_on_active_job_id_and_created_at"
    t.index ["batch_callback_id"], name: "index_good_jobs_on_batch_callback_id", where: "(batch_callback_id IS NOT NULL)"
    t.index ["batch_id"], name: "index_good_jobs_on_batch_id", where: "(batch_id IS NOT NULL)"
    t.index ["concurrency_key", "created_at"], name: "index_good_jobs_on_concurrency_key_and_created_at"
    t.index ["concurrency_key"], name: "index_good_jobs_on_concurrency_key_when_unfinished", where: "(finished_at IS NULL)"
    t.index ["cron_key", "created_at"], name: "index_good_jobs_on_cron_key_and_created_at_cond", where: "(cron_key IS NOT NULL)"
    t.index ["cron_key", "cron_at"], name: "index_good_jobs_on_cron_key_and_cron_at_cond", unique: true, where: "(cron_key IS NOT NULL)"
    t.index ["finished_at"], name: "index_good_jobs_jobs_on_finished_at", where: "((retried_good_job_id IS NULL) AND (finished_at IS NOT NULL))"
    t.index ["labels"], name: "index_good_jobs_on_labels", where: "(labels IS NOT NULL)", using: :gin
    t.index ["locked_by_id"], name: "index_good_jobs_on_locked_by_id", where: "(locked_by_id IS NOT NULL)"
    t.index ["priority", "created_at"], name: "index_good_job_jobs_for_candidate_lookup", where: "(finished_at IS NULL)"
    t.index ["priority", "created_at"], name: "index_good_jobs_jobs_on_priority_created_at_when_unfinished", order: { priority: "DESC NULLS LAST" }, where: "(finished_at IS NULL)"
    t.index ["priority", "scheduled_at"], name: "index_good_jobs_on_priority_scheduled_at_unfinished_unlocked", where: "((finished_at IS NULL) AND (locked_by_id IS NULL))"
    t.index ["queue_name", "scheduled_at"], name: "index_good_jobs_on_queue_name_and_scheduled_at", where: "(finished_at IS NULL)"
    t.index ["scheduled_at"], name: "index_good_jobs_on_scheduled_at", where: "(finished_at IS NULL)"
  end

  create_table "hosting_interests", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "academic_year_id", null: false
    t.uuid "school_id", null: false
    t.enum "appetite", enum_type: "appetite"
    t.jsonb "reasons_not_hosting"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "other_reason_not_hosting"
    t.index ["academic_year_id"], name: "index_hosting_interests_on_academic_year_id"
    t.index ["school_id", "academic_year_id"], name: "index_hosting_interests_on_school_id_and_academic_year_id", unique: true
    t.index ["school_id"], name: "index_hosting_interests_on_school_id"
  end

  create_table "key_stages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.enum "training_type", default: "initial", null: false, enum_type: "mentor_training_type"
    t.integer "hours_completed"
    t.datetime "date_completed"
    t.uuid "claim_id"
    t.uuid "mentor_id"
    t.uuid "provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "rejected", default: false
    t.text "reason_rejected"
    t.boolean "not_assured", default: false
    t.text "reason_not_assured"
    t.integer "hours_clawed_back"
    t.text "reason_clawed_back"
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

  create_table "partnerships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "school_id", null: false
    t.uuid "provider_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_partnerships_on_provider_id"
    t.index ["school_id", "provider_id"], name: "index_partnerships_on_school_id_and_provider_id", unique: true
    t.index ["school_id"], name: "index_partnerships_on_school_id"
  end

  create_table "payment_claims", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "payment_id", null: false
    t.uuid "claim_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_id"], name: "index_payment_claims_on_claim_id"
    t.index ["payment_id"], name: "index_payment_claims_on_payment_id"
  end

  create_table "payment_responses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.boolean "processed", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "downloaded_at"
    t.index ["user_id"], name: "index_payment_responses_on_user_id"
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sent_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "downloaded_at"
    t.index ["sent_by_id"], name: "index_payments_on_sent_by_id"
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

  create_table "placement_additional_subjects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "subject_id", null: false
    t.uuid "placement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["placement_id"], name: "index_placement_additional_subjects_on_placement_id"
    t.index ["subject_id"], name: "index_placement_additional_subjects_on_subject_id"
  end

  create_table "placement_mentor_joins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "mentor_id", null: false
    t.uuid "placement_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mentor_id"], name: "index_placement_mentor_joins_on_mentor_id"
    t.index ["placement_id"], name: "index_placement_mentor_joins_on_placement_id"
  end

  create_table "placement_windows", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "placement_id", null: false
    t.uuid "term_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["placement_id"], name: "index_placement_windows_on_placement_id"
    t.index ["term_id"], name: "index_placement_windows_on_term_id"
  end

  create_table "placements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "provider_id"
    t.uuid "subject_id"
    t.enum "year_group", enum_type: "placement_year_group"
    t.uuid "academic_year_id", null: false
    t.string "creator_type"
    t.uuid "creator_id"
    t.boolean "send_specific", default: false
    t.uuid "key_stage_id"
    t.index ["academic_year_id"], name: "index_placements_on_academic_year_id"
    t.index ["creator_type", "creator_id"], name: "index_placements_on_creator"
    t.index ["key_stage_id"], name: "index_placements_on_key_stage_id"
    t.index ["provider_id"], name: "index_placements_on_provider_id"
    t.index ["school_id"], name: "index_placements_on_school_id"
    t.index ["subject_id"], name: "index_placements_on_subject_id"
    t.index ["year_group"], name: "index_placements_on_year_group"
  end

  create_table "provider_email_addresses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email_address"
    t.uuid "provider_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "primary", default: false
    t.index ["email_address", "provider_id"], name: "unique_provider_email", unique: true
    t.index ["primary"], name: "index_provider_email_addresses_on_primary"
    t.index ["provider_id"], name: "index_provider_email_addresses_on_provider_id"
  end

  create_table "provider_sampling_claims", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "claim_id", null: false
    t.uuid "provider_sampling_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["claim_id"], name: "index_provider_sampling_claims_on_claim_id"
    t.index ["provider_sampling_id"], name: "index_provider_sampling_claims_on_provider_sampling_id"
  end

  create_table "provider_samplings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "sampling_id", null: false
    t.uuid "provider_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "downloaded_at"
    t.index ["provider_id"], name: "index_provider_samplings_on_provider_id"
    t.index ["sampling_id"], name: "index_provider_samplings_on_sampling_id"
  end

  create_table "providers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "placements_service", default: false
    t.enum "provider_type", default: "scitt", null: false, enum_type: "provider_type"
    t.string "name", default: "", null: false
    t.string "ukprn"
    t.string "urn"
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
    t.float "longitude"
    t.float "latitude"
    t.index ["code"], name: "index_providers_on_code", unique: true
    t.index ["latitude"], name: "index_providers_on_latitude"
    t.index ["longitude"], name: "index_providers_on_longitude"
    t.index ["name"], name: "index_providers_on_name_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["placements_service"], name: "index_providers_on_placements_service"
    t.index ["postcode"], name: "index_providers_on_postcode_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["provider_type"], name: "index_providers_on_provider_type"
    t.index ["ukprn"], name: "index_providers_on_ukprn_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["urn"], name: "index_providers_on_urn_trigram", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "regions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.integer "claims_funding_available_per_hour_pence", default: 0, null: false
    t.string "claims_funding_available_per_hour_currency", default: "GBP", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_regions_on_name", unique: true
  end

  create_table "samplings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "school_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "email_address", null: false
    t.uuid "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["school_id"], name: "index_school_contacts_on_school_id"
  end

  create_table "school_sen_provisions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "school_id", null: false
    t.uuid "sen_provision_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_school_sen_provisions_on_school_id"
    t.index ["sen_provision_id"], name: "index_school_sen_provisions_on_sen_provision_id"
  end

  create_table "schools", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "urn"
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
    t.datetime "claims_grant_conditions_accepted_at"
    t.uuid "claims_grant_conditions_accepted_by_id"
    t.jsonb "potential_placement_details"
    t.string "vendor_number"
    t.boolean "expression_of_interest_completed", default: false
    t.boolean "previously_offered_placements", default: false
    t.string "manually_onboarded_by_type"
    t.uuid "manually_onboarded_by_id"
    t.index ["claims_grant_conditions_accepted_by_id"], name: "index_schools_on_claims_grant_conditions_accepted_by_id"
    t.index ["claims_service"], name: "index_schools_on_claims_service"
    t.index ["latitude"], name: "index_schools_on_latitude"
    t.index ["longitude"], name: "index_schools_on_longitude"
    t.index ["manually_onboarded_by_type", "manually_onboarded_by_id"], name: "index_schools_on_manually_onboarded_by"
    t.index ["name"], name: "index_schools_on_name_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["placements_service"], name: "index_schools_on_placements_service"
    t.index ["postcode"], name: "index_schools_on_postcode_trigram", opclass: :gin_trgm_ops, using: :gin
    t.index ["region_id"], name: "index_schools_on_region_id"
    t.index ["trust_id"], name: "index_schools_on_trust_id"
    t.index ["urn"], name: "index_schools_on_urn", unique: true
    t.index ["urn"], name: "index_schools_on_urn_trigram", opclass: :gin_trgm_ops, using: :gin
  end

  create_table "sen_provisions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_sen_provisions_on_name", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "subjects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.enum "subject_area", enum_type: "subject_area"
    t.string "name", null: false
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "parent_subject_id"
    t.index ["parent_subject_id"], name: "index_subjects_on_parent_subject_id"
  end

  create_table "terms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
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
    t.uuid "selected_academic_year_id"
    t.index ["selected_academic_year_id"], name: "index_users_on_selected_academic_year_id"
    t.index ["type", "discarded_at", "email"], name: "index_users_on_type_and_discarded_at_and_email"
    t.index ["type", "email"], name: "index_users_on_type_and_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "claim_activities", "users"
  add_foreign_key "claim_windows", "academic_years"
  add_foreign_key "claims", "providers"
  add_foreign_key "claims", "schools"
  add_foreign_key "clawback_claims", "claims"
  add_foreign_key "clawback_claims", "clawbacks"
  add_foreign_key "eligibilities", "claim_windows"
  add_foreign_key "eligibilities", "schools"
  add_foreign_key "hosting_interests", "academic_years"
  add_foreign_key "hosting_interests", "schools"
  add_foreign_key "mentor_memberships", "mentors"
  add_foreign_key "mentor_memberships", "schools"
  add_foreign_key "mentor_trainings", "claims"
  add_foreign_key "mentor_trainings", "mentors"
  add_foreign_key "mentor_trainings", "providers"
  add_foreign_key "partnerships", "providers"
  add_foreign_key "partnerships", "schools"
  add_foreign_key "payment_claims", "claims"
  add_foreign_key "payment_claims", "payments"
  add_foreign_key "payment_responses", "users"
  add_foreign_key "payments", "users", column: "sent_by_id"
  add_foreign_key "placement_additional_subjects", "placements"
  add_foreign_key "placement_additional_subjects", "subjects"
  add_foreign_key "placement_mentor_joins", "mentors"
  add_foreign_key "placement_mentor_joins", "placements"
  add_foreign_key "placement_windows", "placements"
  add_foreign_key "placement_windows", "terms"
  add_foreign_key "placements", "academic_years"
  add_foreign_key "placements", "providers"
  add_foreign_key "placements", "schools"
  add_foreign_key "placements", "subjects"
  add_foreign_key "provider_email_addresses", "providers"
  add_foreign_key "provider_sampling_claims", "claims"
  add_foreign_key "provider_sampling_claims", "provider_samplings"
  add_foreign_key "provider_samplings", "providers"
  add_foreign_key "provider_samplings", "samplings"
  add_foreign_key "school_contacts", "schools"
  add_foreign_key "school_sen_provisions", "schools"
  add_foreign_key "school_sen_provisions", "sen_provisions"
  add_foreign_key "schools", "regions"
  add_foreign_key "schools", "trusts"
  add_foreign_key "schools", "users", column: "claims_grant_conditions_accepted_by_id"
  add_foreign_key "subjects", "subjects", column: "parent_subject_id"
  add_foreign_key "user_memberships", "users"
end
