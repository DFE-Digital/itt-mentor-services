class CreatePartnerships < ActiveRecord::Migration[7.1]
  def change
    create_table :partnerships, id: :uuid do |t|
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.references :provider, null: false, foreign_key: true, type: :uuid
      t.index %i[school_id provider_id], unique: true

      t.timestamps
    end
  end
end
