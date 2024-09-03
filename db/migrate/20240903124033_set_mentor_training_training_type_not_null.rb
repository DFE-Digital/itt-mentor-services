class SetMentorTrainingTrainingTypeNotNull < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :mentor_trainings, "training_type IS NOT NULL", name: "mentor_trainings_training_type_null",
                                                                         validate: false
  end
end
