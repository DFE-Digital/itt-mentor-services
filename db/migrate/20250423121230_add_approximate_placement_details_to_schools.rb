class AddApproximatePlacementDetailsToSchools < ActiveRecord::Migration[7.2]
  def change
    add_column :schools, :approximate_placement_details, :jsonb
  end
end
