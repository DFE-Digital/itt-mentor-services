# == Schema Information
#
# Table name: users
#
#  id                :uuid             not null, primary key
#  dfe_sign_in_uid   :string
#  email             :string           not null
#  first_name        :string           not null
#  last_name         :string           not null
#  last_signed_in_at :datetime
#  type              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_users_on_type_and_email  (type,email) UNIQUE
#
require "rails_helper"

RSpec.describe Placements::User do
  describe "associations" do
    describe "#schools" do
      it { is_expected.to have_many(:schools).through(:memberships).source(:organisation) }

      it "returns only Placements::School records" do
        placements_user = create(:placements_user)
        placements_school = create(:placements_school)

        placements_user.schools << placements_school
        placements_user.schools << create(:claims_school)

        expect(placements_user.schools).to contain_exactly(placements_school)
        expect(placements_user.schools).to all(be_a(Placements::School))
      end
    end
  end

  describe "default scope" do
    let(:email) { "same_email@email.co.uk" }
    let!(:user_with_placements_service) { create(:placements_user, email:) }
    let!(:user_with_claims_service) { create(:claims_user, email:) }

    it "is scoped to placement service users" do
      user = described_class.find(user_with_placements_service.id)
      expect(described_class.all).to contain_exactly(user)
    end
  end

  describe "#service" do
    it "returns :placements" do
      expect(described_class.new.service).to eq(:placements)
    end
  end

  describe "#organisation_count" do
    describe "returns the count of only placements organisations" do
      it "returns 0 if user has no placement organisations" do
        user = create(:placements_user)
        expect(user.organisation_count).to eq 0

        create(:membership, user:, organisation: create(:claims_school))
        expect(user.organisation_count).to eq 0
      end

      it "returns combined provider and school count" do
        user = create(:placements_user)
        create(:membership, user:, organisation: create(:placements_school))
        create(:membership, user:, organisation: create(:placements_provider))
        create(:membership, user:, organisation: create(:placements_provider))

        expect(user.organisation_count).to eq 3
      end
    end
  end
end
