class RemoveBulkAddPlacementsFlipperFlag < ActiveRecord::Migration[7.2]
  def up
    Flipper.remove(:bulk_add_placements)
  end
end
