class AddPotentialPlacementDetailsToSchools < ActiveRecord::Migration[7.2]
  def change
    add_column :schools, :potential_placement_details, :jsonb
  end
end
