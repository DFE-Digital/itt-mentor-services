# == Schema Information
#
# Table name: mentor_trainings
#
#  id              :uuid             not null, primary key
#  date_completed  :datetime
#  hours_completed :integer
#  training_type   :enum             not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  claim_id        :uuid
#  mentor_id       :uuid
#  provider_id     :uuid
#
# Indexes
#
#  index_mentor_trainings_on_claim_id     (claim_id)
#  index_mentor_trainings_on_mentor_id    (mentor_id)
#  index_mentor_trainings_on_provider_id  (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (claim_id => claims.id)
#  fk_rails_...  (mentor_id => mentors.id)
#  fk_rails_...  (provider_id => providers.id)
#
require "rails_helper"

RSpec.describe Claims::MentorTraining, type: :model do
  subject(:mentor_training) { described_class.new }

  context "with associations" do
    it { is_expected.to belong_to(:claim) }
    it { is_expected.to belong_to(:mentor).optional }
    it { is_expected.to belong_to(:provider).optional }
  end

  describe "auditing" do
    it { is_expected.to be_audited.associated_with(:claim) }
  end

  context "with validations" do
    it {
      expect(mentor_training).to validate_numericality_of(:hours_completed)
      .only_integer
      .is_greater_than(0)
      .is_less_than_or_equal_to(20)
      .allow_nil
    }
  end

  context "with scopes" do
    describe "#without_hours" do
      it "returns mentor_trainings without completed hours ordered by mentor first nameand last name" do
        mentor1 = create(:mentor, first_name: "Anne", last_name: "Doe")
        mentor2 = create(:mentor, first_name: "Anne", last_name: "Smith")
        mentor_training1 = create(:mentor_training, mentor: mentor1)
        mentor_training2 = create(:mentor_training, mentor: mentor2)
        create(:mentor_training, hours_completed: 12, mentor: create(:mentor))

        expect(described_class.without_hours).to eq(
          [mentor_training1, mentor_training2],
        )
      end
    end

    describe "#order_by_mentor_full_name" do
      it "returns the mentor_trainings ordered by mentor first name and last name" do
        mentor1 = create(:mentor, first_name: "Anne", last_name: "Doe")
        mentor2 = create(:mentor, first_name: "Anne", last_name: "Smith")
        mentor3 = create(:mentor, first_name: "John", last_name: "Doe")
        mentor_training1 = create(:mentor_training, mentor: mentor1)
        mentor_training2 = create(:mentor_training, mentor: mentor2)
        mentor_training3 = create(:mentor_training, mentor: mentor3)

        expect(described_class.order_by_mentor_full_name).to eq(
          [mentor_training1, mentor_training2, mentor_training3],
        )
      end
    end
  end

  context "with delegations" do
    it { is_expected.to delegate_method(:full_name).to(:mentor).with_prefix.allow_nil }
  end
end
