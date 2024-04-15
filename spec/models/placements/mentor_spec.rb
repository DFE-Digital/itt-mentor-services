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
# Indexes
#
#  index_mentors_on_trn  (trn) UNIQUE
#
require "rails_helper"

RSpec.describe Placements::Mentor, type: :model do
  context "with associations" do
    it { is_expected.to have_many(:mentor_memberships) }
    it { is_expected.to have_many(:schools).through(:mentor_memberships) }

    it { is_expected.to have_many(:placement_mentor_joins) }
    it { is_expected.to have_many(:placements).through(:placement_mentor_joins) }
  end

  describe "default scope" do
    it "returns only mentors with mentor memberships on the placements service" do
      mentor = create(:placements_mentor)
      create(
        :mentor_membership,
        :placements,
        mentor:,
      )

      claims_mentor = create(:claims_mentor)
      create(
        :mentor_membership,
        :claims,
        mentor: claims_mentor,
      )

      expect(described_class.all).to contain_exactly(mentor)
      expect(described_class.all).not_to include(claims_mentor)
    end
  end
end
