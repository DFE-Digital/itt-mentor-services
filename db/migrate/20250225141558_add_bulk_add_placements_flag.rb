class AddBulkAddPlacementsFlag < ActiveRecord::Migration[7.2]
  def change
    Flipper.add(:bulk_add_placements)
  end
end
