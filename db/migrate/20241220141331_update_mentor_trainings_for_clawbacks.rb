class UpdateMentorTrainingsForClawbacks < ActiveRecord::Migration[7.2]
  def change
    remove_column :mentor_trainings, :hours_rejected
    add_column :mentor_trainings, :hours_clawed_back, :integer
    add_column :mentor_trainings, :reason_clawed_back, :text
  end
end
