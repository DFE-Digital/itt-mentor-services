class CreateDeletedEntities < ActiveRecord::Migration[8.0]
  def change
    create_table :deleted_entities, id: :uuid do |t|
      t.string :entity_id, null: false
      t.string :entity_name, null: false
      t.jsonb :deleted_records, null: false, default: {}

      t.timestamps
    end
  end
end
