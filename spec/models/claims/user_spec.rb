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

RSpec.describe Claims::User do
  describe "associations" do
    it { should have_many(:schools).through(:memberships).source(:organisation) }

    it "association returns Claims::Schools objects" do
      claims_user = create(:claims_user)
      claims_user.memberships.create!(organisation: create(:school, :claims))
      expect(claims_user.schools.first.class.name).to eq "Claims::School"
    end
  end

  describe "default scope" do
    let(:email) { "same_email@email.co.uk" }
    let!(:user_with_claims_service) { create(:claims_user, email:) }
    let!(:user_with_placements_service) { create(:placements_user, email:) }

    it "is scoped to users of the claims service" do
      user = described_class.find(user_with_claims_service.id)
      expect(described_class.all).to contain_exactly(user)
    end
  end

  describe "#service" do
    it "returns :claims" do
      expect(described_class.new.service).to eq(:claims)
    end
  end
end
