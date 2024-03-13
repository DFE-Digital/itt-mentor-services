class RemoveDraftFromClaim < ActiveRecord::Migration[7.1]
  def change
    remove_column :claims, :draft, :boolean, default: false
  end
end
