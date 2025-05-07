class AddProviderFindPlacementsFlag < ActiveRecord::Migration[7.2]
  def change
    Flipper.add(:provider_hide_find_placements)

    hide_providers = Placements::Provider.where(code: %w[H40 2B1])
    hide_providers.each do |provider|
      Flipper.enable_actor(:provider_hide_find_placements, provider)
    end
  end
end
