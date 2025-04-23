class AddHidePlacementsFlag < ActiveRecord::Migration[7.2]
  def change
    Flipper.add(:show_provider_placements)
  end
end
