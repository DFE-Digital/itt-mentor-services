class AddRegionToSchool < ActiveRecord::Migration[7.1]
  def change
    add_reference :schools, :region, type: :uuid, foreign_key: true
  end
end
