# == Schema Information
#
# Table name: mentors
#
#  id         :uuid             not null, primary key
#  first_name :string           not null
#  last_name  :string           not null
#  trn        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe Claims::Mentor, type: :model do
  context "with associations" do
    it { is_expected.to have_many(:mentor_memberships) }
    it { is_expected.to have_many(:schools).through(:mentor_memberships) }
  end

  describe "default scope" do
    it "returns only mentors with mentor memberships on the claims service" do
      mentor = create(:claims_mentor)
      create(
        :mentor_membership,
        :claims,
        mentor:,
      )
      placements_mentor = create(:placements_mentor)
      create(
        :mentor_membership,
        :placements,
        mentor: placements_mentor,
      )

      expect(described_class.all).to contain_exactly(mentor)
      expect(described_class.all).not_to include(placements_mentor)
    end
  end
end
