class CreateClaimsClaimWindows < ActiveRecord::Migration[7.1]
  def change
    create_table :claim_windows, id: :uuid do |t|
      t.references :academic_year, null: false, foreign_key: true, type: :uuid
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.date :discarded_at, index: true

      t.timestamps
    end
  end
end
