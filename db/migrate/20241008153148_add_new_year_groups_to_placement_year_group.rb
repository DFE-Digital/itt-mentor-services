class AddNewYearGroupsToPlacementYearGroup < ActiveRecord::Migration[7.2]
  def change
    add_enum_value :placement_year_group, "nursery", before: "year_1"
    add_enum_value :placement_year_group, "reception", before: "year_1"
  end
end
