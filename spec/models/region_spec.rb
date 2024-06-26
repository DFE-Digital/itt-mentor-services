# == Schema Information
#
# Table name: regions
#
#  id                                         :uuid             not null, primary key
#  claims_funding_available_per_hour_currency :string           default("GBP"), not null
#  claims_funding_available_per_hour_pence    :integer          default(0), not null
#  name                                       :string           not null
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#
# Indexes
#
#  index_regions_on_name  (name) UNIQUE
#
require "rails_helper"

RSpec.describe Region, type: :model do
  context "with associations" do
    it { is_expected.to have_many(:schools) }
  end

  context "with validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:claims_funding_available_per_hour_currency) }
    it { is_expected.to validate_presence_of(:claims_funding_available_per_hour_pence) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  describe "#funding_available_per_hour" do
    subject(:region) { described_class.new(claims_funding_available_per_hour_currency: "GBP", claims_funding_available_per_hour_pence: 4510) }

    it "returns the funding available per hour" do
      expect(region.funding_available_per_hour).to eq(Money.from_amount(45.10, "GBP"))
    end
  end
end
