# == Schema Information
#
# Table name: providers
#
#  id               :uuid             not null, primary key
#  city             :string
#  county           :string
#  email            :string
#  name             :string           not null
#  placements       :boolean          default(FALSE)
#  postcode         :string
#  provider_code    :string           not null
#  provider_type    :enum             not null
#  street_address_1 :string
#  street_address_2 :string
#  street_address_3 :string
#  telephone        :string
#  town             :string
#  ukprn            :string
#  urn              :string
#  website          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_providers_on_placements     (placements)
#  index_providers_on_provider_code  (provider_code) UNIQUE
#
require "rails_helper"

RSpec.describe Provider, type: :model do
  context "associations" do
    it { should have_many(:memberships) }
  end

  context "validations" do
    subject { build(:provider) }

    it { is_expected.to validate_presence_of(:provider_code) }
    it { is_expected.to validate_presence_of(:name) }
    it do
      is_expected.to validate_uniqueness_of(
        :provider_code,
      ).case_insensitive.with_message("This provider has already been added. Try another provider")
    end
    it { is_expected.to allow_values("scitt", "lead_school", "university").for(:provider_type) }
  end
end
