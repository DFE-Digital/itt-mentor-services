class ValidateMentorTrainingTrainingTypeNotNull < ActiveRecord::Migration[7.1]
  def up
    validate_check_constraint :mentor_trainings, name: "mentor_trainings_training_type_null"
    change_column_null :mentor_trainings, :training_type, false
    remove_check_constraint :mentor_trainings, name: "mentor_trainings_training_type_null"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
