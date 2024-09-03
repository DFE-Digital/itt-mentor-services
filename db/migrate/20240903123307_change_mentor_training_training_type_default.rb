class ChangeMentorTrainingTrainingTypeDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :mentor_trainings, :training_type, from: nil, to: "initial"
  end
end
