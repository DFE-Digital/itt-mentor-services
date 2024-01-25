class CreateClaims < ActiveRecord::Migration[7.1]
  def change
    create_table :claims, id: :uuid do |t|
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.boolean :draft, default: false

      t.timestamps
    end
  end
end
