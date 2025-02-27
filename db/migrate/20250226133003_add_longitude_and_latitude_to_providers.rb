class AddLongitudeAndLatitudeToProviders < ActiveRecord::Migration[7.2]
  def change
    safety_assured do
      change_table(:providers, bulk: true) do |provider|
        provider.float :longitude, :latitude, index: true
      end
    end
  end
end
