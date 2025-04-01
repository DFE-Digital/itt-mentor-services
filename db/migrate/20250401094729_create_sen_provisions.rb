class CreateSENProvisions < ActiveRecord::Migration[7.2]
  def change
    create_table :sen_provisions, id: :uuid do |t|
      t.string :name, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
