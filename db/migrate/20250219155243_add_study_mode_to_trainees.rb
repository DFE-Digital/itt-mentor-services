class AddStudyModeToTrainees < ActiveRecord::Migration[7.2]
  def change
    add_column :trainees, :study_mode, :string
  end
end
