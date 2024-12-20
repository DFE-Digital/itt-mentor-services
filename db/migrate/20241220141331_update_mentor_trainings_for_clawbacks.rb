class UpdateMentorTrainingsForClawbacks < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      change_table(:mentor_trainings, bulk: true) do |t|
        t.remove :hours_rejected, type: :integer
        t.integer :hours_clawed_back
        t.text :reason_clawed_back
      end
    end
  end
end
