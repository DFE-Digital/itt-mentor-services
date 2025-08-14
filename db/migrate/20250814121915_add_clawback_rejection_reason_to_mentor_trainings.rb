class AddClawbackRejectionReasonToMentorTrainings < ActiveRecord::Migration[8.0]
  def change
    add_column :mentor_trainings, :reason_clawback_rejected, :text
  end
end
