class AddUuidAndNameToCourses < ActiveRecord::Migration[7.2]
  def change
    change_table :courses, bulk: true do |t|
      t.string :uuid
      t.string :name
    end
  end
end
