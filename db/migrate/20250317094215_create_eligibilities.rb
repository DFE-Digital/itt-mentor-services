class CreateEligibilities < ActiveRecord::Migration[7.2]
  def change
    create_table :eligibilities, id: :uuid do |t|
      t.references :claim_window, null: false, foreign_key: true, type: :uuid
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.timestamps
    end
  end
end
