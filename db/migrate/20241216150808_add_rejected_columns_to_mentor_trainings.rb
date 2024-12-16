class AddRejectedColumnsToMentorTrainings < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      change_table(:mentor_trainings, bulk: true) do |t|
        t.boolean :rejected, default: false
        t.text :reason_rejected
        t.integer :hours_rejected
      end
    end
  end
end
