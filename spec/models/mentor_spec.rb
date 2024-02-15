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
#  school_id  :uuid             not null
#
# Indexes
#
#  index_mentors_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
require "rails_helper"

RSpec.describe Mentor, type: :model do
  context "with associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to have_many(:mentor_memberships) }
    it { is_expected.to have_many(:schools).through(:mentor_memberships) }
  end

  context "with validations" do
    subject { build(:mentor) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:trn) }
  end

  describe "#full_name" do
    it "returns the mentors full name" do
      mentor = build(:mentor, first_name: "Jane", last_name: "Doe")
      expect(mentor.full_name).to eq("Jane Doe")
    end
  end
end
