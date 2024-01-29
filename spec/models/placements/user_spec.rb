# == Schema Information
#
# Table name: users
#
#  id         :uuid             not null, primary key
#  email      :string           not null
#  first_name :string           not null
#  last_name  :string           not null
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_type_and_email  (type,email) UNIQUE
#
require "rails_helper"

RSpec.describe Placements::User do
  describe "associations" do
    context "#schools" do
      it { should have_many(:schools).through(:memberships).source(:organisation) }

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
end
