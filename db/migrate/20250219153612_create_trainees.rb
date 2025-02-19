class CreateTrainees < ActiveRecord::Migration[7.2]
  def change
    create_table :trainees, id: :uuid do |t|
      t.string :candidate_id
      t.string :itt_course_code
      t.string :training_provider_code

      t.timestamps
    end
  end
end
