class BackFillMentorTrainingTrainingType < ActiveRecord::Migration[7.1]
  def up
    # We require callbacks for BigQuery to stay in sync with the data.
    Claims::MentorTraining.find_each do |mentor_training|
      mentor_training.update(training_type: Claims::MentorTraining.training_types[:initial])
    end
  end
end
