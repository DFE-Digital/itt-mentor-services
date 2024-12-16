class AddAssuredColumnsToMentorTrainings < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      change_table(:mentor_trainings, bulk: true) do |t|
        t.boolean :assured, default: false
        t.text :reason_not_assured
      end
    end
  end
end
