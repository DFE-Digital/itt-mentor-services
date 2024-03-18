class AddLatitudeAndLongitudeToSchools < ActiveRecord::Migration[7.1]
  def change
    change_table(:schools) do |school|
      school.float :longitude, :latitude, index: true
    end
  end
end
