class CreateClaimStatusChanges < ActiveRecord::Migration[8.1]
  def change
    create_table :claim_status_changes, id: :uuid do |t|
      t.references :claim, type: :uuid, null: false
      t.string :from_status
      t.string :to_status, null: false
      t.datetime :occurred_at
      t.references :actor, type: :uuid, polymorphic: true
      t.string :actor_name
      t.string :actor_kind, null: false
      t.string :system_operation
      t.references :source, type: :uuid, polymorphic: true
      t.string :operation_id
      t.bigint :sequence, null: false
      t.bigint :legacy_audit_id
      t.jsonb :details, null: false, default: {}
      t.boolean :imported, null: false, default: false
      t.timestamps
    end

    add_index :claim_status_changes, %i[claim_id sequence], unique: true
    add_index :claim_status_changes, %i[claim_id operation_id], unique: true
    add_index :claim_status_changes, :legacy_audit_id, unique: true
    add_check_constraint :claim_status_changes, "sequence > 0", name: "claim_status_changes_positive_sequence"
    add_check_constraint :claim_status_changes,
                         "actor_kind IN ('user', 'system', 'unknown') AND (imported OR (occurred_at IS NOT NULL AND ((actor_kind = 'user' AND actor_id IS NOT NULL AND actor_type IS NOT NULL) OR (actor_kind = 'system' AND system_operation IS NOT NULL AND length(trim(system_operation)) > 0))))",
                         name: "claim_status_changes_attribution"
    add_check_constraint :claim_status_changes, "from_status IS NULL OR from_status <> to_status", name: "claim_status_changes_real_transition"
  end
end
