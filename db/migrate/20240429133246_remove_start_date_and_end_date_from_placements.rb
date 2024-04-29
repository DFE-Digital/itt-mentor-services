class RemoveStartDateAndEndDateFromPlacements < ActiveRecord::Migration[7.1]
  def change
    change_table :placements, bulk: true do |t|
      t.remove :start_date, :end_date, type: :date
    end
  end
end
