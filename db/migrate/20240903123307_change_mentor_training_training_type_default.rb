class ChangeMentorTrainingTrainingTypeDefault < ActiveRecord::Migration[7.1]
  class MentorTrainingForMigration < ApplicationRecord
    self.table_name = :mentor_trainings
  end

  def change
    change_column_default :mentor_trainings, :training_type, from: nil, to: "initial"

    up_only do
      # We require callbacks for BigQuery to stay in sync with the data.
      MentorTrainingForMigration.where(training_type: nil).find_each do |mentor_training|
        mentor_training.update(training_type: "initial")
      end
    end
  end
end
