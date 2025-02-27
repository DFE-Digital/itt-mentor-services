class AddSubjectColumnToTrainee < ActiveRecord::Migration[7.2]
  def change
    add_column :trainees, :degree_subject, :string
  end
end
