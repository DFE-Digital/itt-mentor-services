class ClaimBelongsToProvider < ActiveRecord::Migration[7.1]
  def change
    add_reference :claims, :provider, null: true, foreign_key: true, type: :uuid
  end
end
