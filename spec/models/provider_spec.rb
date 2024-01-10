# == Schema Information
#
# Table name: providers
#
#  id            :uuid             not null, primary key
#  address1      :string
#  address2      :string
#  address3      :string
#  city          :string
#  code          :string           not null
#  county        :string
#  email_address :string
#  name          :string           not null
#  placements    :boolean          default(FALSE)
#  postcode      :string
#  provider_type :enum             not null
#  telephone     :string
#  town          :string
#  ukprn         :string
#  urn           :string
#  website       :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_providers_on_code        (code) UNIQUE
#  index_providers_on_placements  (placements)
#
require "rails_helper"

RSpec.describe Provider, type: :model do
  context "associations" do
    it { should have_many(:memberships) }
  end

  context "validations" do
    subject { build(:provider) }

    it { is_expected.to validate_presence_of(:code) }
    it { is_expected.to validate_presence_of(:name) }
    it do
      is_expected.to validate_uniqueness_of(
        :code,
      ).case_insensitive
    end
    it { is_expected.to allow_values("scitt", "lead_school", "university").for(:provider_type) }
  end
end
