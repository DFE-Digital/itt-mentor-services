# == Schema Information
#
# Table name: grant_conditions_acceptances
#
#  id               :uuid             not null, primary key
#  accepted_at      :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  academic_year_id :uuid             not null
#  accepted_by_id   :uuid             not null
#  school_id        :uuid             not null
#
# Indexes
#
#  index_grant_conditions_acceptances_on_academic_year_id          (academic_year_id)
#  index_grant_conditions_acceptances_on_accepted_by_id            (accepted_by_id)
#  index_grant_conditions_acceptances_on_school_and_academic_year  (school_id,academic_year_id) UNIQUE
#  index_grant_conditions_acceptances_on_school_id                 (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (academic_year_id => academic_years.id)
#  fk_rails_...  (accepted_by_id => users.id)
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
require "rails_helper"

RSpec.describe Claims::GrantConditionsAcceptance, type: :model do
  context "with associations" do
    it { is_expected.to belong_to(:school).class_name("Claims::School") }
    it { is_expected.to belong_to(:academic_year) }
    it { is_expected.to belong_to(:accepted_by).class_name("::User") }

    it "returns the accepting user when they are a support user" do
      support_user = create(:claims_support_user)
      acceptance = create(:grant_conditions_acceptance, accepted_by: support_user)

      expect(acceptance.reload.accepted_by).to eq(support_user)
    end

    it "returns the accepting user even if they have since been removed" do
      acceptance = create(:grant_conditions_acceptance)
      acceptance.accepted_by.discard!

      expect(acceptance.reload.accepted_by).to be_present
    end
  end

  context "with validations" do
    subject(:acceptance) { build(:grant_conditions_acceptance, school: create(:claims_school, grant_conditions_accepted: false)) }

    it { is_expected.to validate_presence_of(:accepted_at) }

    it "does not allow a school to accept the grant conditions twice for the same academic year" do
      create(:grant_conditions_acceptance, school: acceptance.school, academic_year: acceptance.academic_year)

      expect(acceptance).not_to be_valid
    end

    it "allows a school to accept the grant conditions for different academic years" do
      create(:grant_conditions_acceptance, school: acceptance.school, academic_year: acceptance.academic_year.previous)

      expect(acceptance).to be_valid
    end
  end

  it "is unique at the database level" do
    existing = create(:grant_conditions_acceptance)
    duplicate = build(:grant_conditions_acceptance, school: existing.school, academic_year: existing.academic_year)

    expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "is deleted along with its school at the database level" do
    acceptance = create(:grant_conditions_acceptance)

    School.where(id: acceptance.school_id).delete_all

    expect(described_class.exists?(acceptance.id)).to be(false)
  end

  describe ".order_by_latest" do
    it "orders acceptances with the most recently accepted first" do
      school = create(:claims_school, grant_conditions_accepted: false)
      older = create(:grant_conditions_acceptance, school:, academic_year: AcademicYear.current.previous, accepted_at: 1.year.ago)
      newer = create(:grant_conditions_acceptance, school:, academic_year: AcademicYear.current, accepted_at: Time.current)

      expect(described_class.order_by_latest).to eq([newer, older])
    end
  end
end
