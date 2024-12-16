class CreateClaimsClaimActivities < ActiveRecord::Migration[7.2]
  def change
    create_table :claim_activities, id: :uuid do |t|
      t.string :action
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :record, null: false, polymorphic: true, type: :uuid

      t.timestamps
    end
  end
end
