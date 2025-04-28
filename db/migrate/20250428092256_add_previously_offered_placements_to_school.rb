class AddPreviouslyOfferedPlacementsToSchool < ActiveRecord::Migration[7.2]
  def change
    add_column :schools, :previously_offered_placements, :boolean, default: false
  end
end
