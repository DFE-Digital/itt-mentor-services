class AddSchoolPartnerProvidersFlag < ActiveRecord::Migration[7.2]
  def change
    Flipper.add(:school_partner_providers)
  end
end
