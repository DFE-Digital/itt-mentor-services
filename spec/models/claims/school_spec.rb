# == Schema Information
#
# Table name: schools
#
#  id                           :uuid             not null, primary key
#  address1                     :string
#  address2                     :string
#  address3                     :string
#  admissions_policy            :string
#  claims                       :boolean          default(FALSE)
#  email_address                :string
#  gender                       :string
#  group                        :string
#  last_inspection_date         :date
#  maximum_age                  :integer
#  minimum_age                  :integer
#  name                         :string
#  percentage_free_school_meals :integer
#  phase                        :string
#  placements                   :boolean          default(FALSE)
#  postcode                     :string
#  rating                       :string
#  religious_character          :string
#  school_capacity              :integer
#  send_provision               :string
#  special_classes              :string
#  telephone                    :string
#  total_boys                   :integer
#  total_girls                  :integer
#  total_pupils                 :integer
#  town                         :string
#  training_with_disabilities   :string
#  type_of_establishment        :string
#  ukprn                        :string
#  urban_or_rural               :string
#  urn                          :string           not null
#  website                      :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
# Indexes
#
#  index_schools_on_claims      (claims)
#  index_schools_on_placements  (placements)
#  index_schools_on_urn         (urn) UNIQUE
#
require "rails_helper"

RSpec.describe Claims::School do
  describe "default scope" do
    let!(:school_with_claims) { create(:school, :claims) }
    let!(:school_without_claims) { create(:school) }

    it "is scoped to schools using the claims service" do
      school = described_class.find(school_with_claims.id)
      expect(described_class.all).to contain_exactly(school)
    end
  end
end
