# == Schema Information
#
# Table name: providers
#
#  id                 :uuid             not null, primary key
#  accredited         :boolean          default(FALSE)
#  address1           :string
#  address2           :string
#  address3           :string
#  city               :string
#  code               :string           not null
#  county             :string
#  email_address      :string
#  name               :string           not null
#  placements_service :boolean          default(FALSE)
#  postcode           :string
#  provider_type      :enum             not null
#  telephone          :string
#  town               :string
#  ukprn              :string
#  urn                :string
#  website            :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_providers_on_code                (code) UNIQUE
#  index_providers_on_placements_service  (placements_service)
#
require "rails_helper"

RSpec.describe Placements::Provider do
  describe "#assocations" do
    it { should have_many(:users).through(:memberships) }
  end

  describe "default scope" do
    let!(:provider_with_placements) { create(:provider, :placements) }
    let!(:provider_without_placements) { create(:provider) }

    it "is scoped to providers using the placement service" do
      provider = described_class.find(provider_with_placements.id)
      expect(described_class.all).to contain_exactly(provider)
    end
  end
end
