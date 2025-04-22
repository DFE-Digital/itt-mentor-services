class AddMixedYearGroupToPlacementYearGroupEnum < ActiveRecord::Migration[7.2]
  def change
    add_enum_value :placement_year_group, "mixed_year_groups"
  end
end
