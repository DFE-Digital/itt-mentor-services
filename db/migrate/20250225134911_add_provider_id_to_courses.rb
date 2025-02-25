class AddProviderIdToCourses < ActiveRecord::Migration[7.2]
  def change
    add_column :courses, :provider_id, :string
  end
end
