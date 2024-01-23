class RenameSchoolServiceAttributes < ActiveRecord::Migration[7.1]
  def change
    change_table :schools do |t|
      t.rename :claims, :claims_service
      t.rename :placements, :placements_service
    end
  end
end
