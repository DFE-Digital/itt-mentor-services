class AddLatLongIndex < ActiveRecord::Migration[7.1]
  def change
    add_index :applicants, %i[latitude longitude]
    add_index :schools, %i[latitude longitude]
  end
end
