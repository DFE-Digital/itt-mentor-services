class CreateActivityLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :activity_logs, id: :uuid do |t|
      t.string :activity
      t.enum :service, enum_type: :service
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :record, polymorphic: true, null: false, type: :uuid

      t.timestamps
    end
  end
end
