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
    subject { create(:region) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:claims_funding_available_per_hour_currency) }
    it { is_expected.to validate_presence_of(:claims_funding_available_per_hour_pence) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end
end
