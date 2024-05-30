class AddYearGroupToPlacement < ActiveRecord::Migration[7.1]
  create_enum :placement_year_group, %w[year_1 year_2 year_3 year_4 year_5 year_6]

  def change
    add_column :placements, :year_group, :enum, enum_type: :placement_year_group
  end
end
