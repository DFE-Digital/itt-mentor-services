class CreateMentorTrainings < ActiveRecord::Migration[7.1]
  def change
    create_enum :mentor_training_type, %w[refresher initial]

    create_table :mentor_trainings, id: :uuid do |t|
      t.enum :training_type, enum_type: "mentor_training_type"
      t.integer :hours_completed
      t.datetime :date_completed
      t.references :claim, null: true, foreign_key: true, type: :uuid
      t.references :mentor, null: true, foreign_key: true, type: :uuid
      t.references :provider, null: true, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
