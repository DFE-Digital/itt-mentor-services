class CreateTrusts < ActiveRecord::Migration[7.1]
  def change
    create_table :trusts, id: :uuid do |t|
      t.string :uid, null: false
      t.index :uid, unique: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
