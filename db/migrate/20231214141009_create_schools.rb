class CreateSchools < ActiveRecord::Migration[7.1]
  def change
    create_table :schools, id: :uuid do |t|
      t.string :urn, null: false, index: { unique: true }
      t.boolean :placements, default: false, index: true
      t.boolean :claims, default: false, index: true

      t.timestamps
    end
  end
end
