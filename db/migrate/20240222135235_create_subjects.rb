class CreateSubjects < ActiveRecord::Migration[7.1]
  def change
    create_enum :subject_area, %w[primary secondary]

    create_table :subjects, id: :uuid do |t|
      t.enum :subject_area, enum_type: "subject_area"
      t.string :name, null: false
      t.string :code

      t.timestamps
    end
  end
end
