# == Schema Information
#
# Table name: mentor_trainings
#
#  id                 :uuid             not null, primary key
#  date_completed     :datetime
#  hours_clawed_back  :integer
#  hours_completed    :integer
#  not_assured        :boolean          default(FALSE)
#  reason_clawed_back :text
#  reason_not_assured :text
#  reason_rejected    :text
#  rejected           :boolean          default(FALSE)
#  training_type      :enum             default("initial"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  claim_id           :uuid
#  mentor_id          :uuid
#  provider_id        :uuid
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
  subject(:mentor_training) { build(:mentor_training) }

  let(:draft_claim) { build(:claim, :draft) }

  describe "associations" do
    it { is_expected.to belong_to(:claim) }
    it { is_expected.to belong_to(:mentor) }
    it { is_expected.to belong_to(:provider) }
  end

  describe "validations" do
    describe "reason_not_assured" do
      context "when not_assured is true" do
        let(:mentor_training) { build(:mentor_training, not_assured: true) }

        it "validates that the reason not assured is present" do
          expect(mentor_training.valid?).to be(false)
          expect(mentor_training.errors["reason_not_assured"]).to include("can't be blank")
        end
      end

      context "when not_assured is false" do
        let(:mentor_training) { build(:mentor_training, not_assured: false) }

        it "confirms the mentor training is valid" do
          expect(mentor_training.valid?).to be(true)
        end
      end
    end

    describe "rejected" do
      context "when rejected is true" do
        let(:mentor_training) { build(:mentor_training, rejected: true) }

        it "validates that the rejected reason is present" do
          expect(mentor_training.valid?).to be(false)
          expect(mentor_training.errors["reason_rejected"]).to include("can't be blank")
        end
      end

      context "when rejected is false" do
        let(:mentor_training) { build(:mentor_training, rejected: false) }

        it "confirms the mentor training is valid" do
          expect(mentor_training.valid?).to be(true)
        end
      end
    end
  end

  describe "auditing" do
    it { is_expected.to be_audited.associated_with(:claim) }
  end

  describe "enums" do
    it "defines the expected values for training_type" do
      expect(mentor_training).to define_enum_for(:training_type)
        .with_values(initial: "initial", refresher: "refresher")
        .backed_by_column_of_type(:enum)
        .with_default(:initial)
    end
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:full_name).to(:mentor).with_prefix.allow_nil }
    it { is_expected.to delegate_method(:name).to(:provider).with_prefix.allow_nil }
    it { is_expected.to delegate_method(:school).to(:claim) }
    it { is_expected.to delegate_method(:region).to(:school) }
    it { is_expected.to delegate_method(:region_funding_available_per_hour).to(:school) }
  end

  describe "#hours_completed" do
    subject(:mentor_training) { create(:mentor_training, claim: draft_claim) }

    context "with initial training" do
      let(:maximum_hours_allowed) { 20 }

      it {
        expect(mentor_training).to validate_numericality_of(:hours_completed)
          .only_integer
          .is_greater_than(0)
          .is_less_than_or_equal_to(maximum_hours_allowed)
      }
    end

    context "with refresher training" do
      let(:maximum_hours_allowed) { 6 }

      before do
        # Create initial training in a previous academic year
        create(
          :claim, :submitted,
          claim_window: build(:claim_window, :historic),
          mentor_trainings: [build(:mentor_training, mentor: mentor_training.mentor, provider: mentor_training.provider)]
        )
      end

      it {
        expect(mentor_training).to validate_numericality_of(:hours_completed)
          .only_integer
          .is_greater_than(0)
          .is_less_than_or_equal_to(maximum_hours_allowed)
      }
    end
  end

  describe "scopes" do
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

    describe "#not_assured" do
      let(:assured_mentor_training) { create(:mentor_training) }
      let(:not_assured_mentor_training) do
        create(:mentor_training, not_assured: true, reason_not_assured: "Reason")
      end

      it "returns a list of not assured claims" do
        expect(described_class.not_assured).to contain_exactly(not_assured_mentor_training)
      end
    end

    describe "#rejected" do
      let(:not_rejected_mentor_training) { create(:mentor_training) }
      let(:rejected_mentor_training) do
        create(:mentor_training, rejected: true, reason_rejected: "Reason")
      end

      it "returns a list of rejected claims" do
        expect(described_class.rejected).to contain_exactly(rejected_mentor_training)
      end
    end
  end

  describe "#set_training_type" do
    it "sets the training type as calculated by Claims::TrainingAllowance" do
      mock_training_allowance = instance_double(Claims::TrainingAllowance)
      allow(Claims::TrainingAllowance).to receive(:new).and_return(mock_training_allowance)
      allow(mock_training_allowance).to receive(:training_type).and_return("pineapple")

      mentor_training.set_training_type

      expect(mentor_training.training_type).to eq("pineapple")
    end
  end

  describe "#corrected_hours_completed" do
    subject(:corrected_hours_completed) { mentor_training.corrected_hours_completed }

    let(:mentor_training) { build(:mentor_training, hours_completed: 20, hours_clawed_back: 5) }

    it "returns the hours_completed minus the hours_clawed_back" do
      expect(corrected_hours_completed).to eq(15)
    end
  end

  describe "#clawback_amount" do
    subject(:clawback_amount) { mentor_training.clawback_amount }

    let(:mentor_training) { create(:mentor_training, hours_completed: 20, hours_clawed_back: 5) }

    it "returns the amount claimed back for the mentor training" do
      expect(clawback_amount.to_f).to eq(225.5)
    end
  end
end
