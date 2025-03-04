require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::SecondaryChildSubjectPlacementSelectionStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        school:,
      )
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }
  let(:state) { {} }

  describe "delegations" do
    it { is_expected.to delegate_method(:child_subjects).to(:subject) }
  end

  describe "attributes" do
    it {
      expect(step).to have_attributes(
        parent_subject_id: nil, selection_id: nil, selection_number: nil, child_subject_ids: [],
      )
    }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:parent_subject_id) }
    it { is_expected.to validate_presence_of(:selection_id) }
    it { is_expected.to validate_presence_of(:selection_number) }
    it { is_expected.to validate_presence_of(:child_subject_ids) }
  end

  describe "#subject" do
    subject(:parent_subject) { step.subject }

    let(:a_parent_subject) { create(:subject) }
    let(:attributes) { { parent_subject_id: a_parent_subject.id } }

    it "returns the parent subject" do
      expect(parent_subject).to eq(a_parent_subject)
    end
  end

  describe "#child_subject_ids" do
    subject(:child_subject_ids) { step.child_subject_ids }

    context "when child_subject_ids is blank" do
      it "returns an empty array" do
        expect(child_subject_ids).to eq([])
      end
    end

    context "when the child_subject_ids attribute contains a blank element" do
      let(:attributes) { { child_subject_ids: ["123", nil] } }

      it "removes the nil element from the child_subject_ids attribute" do
        expect(child_subject_ids).to contain_exactly("123")
      end
    end

    context "when the child_subject_ids attribute contains no blank elements" do
      let(:attributes) { { child_subject_ids: %w[123 456] } }

      it "returns the child_subject_ids attribute unchanged" do
        expect(child_subject_ids).to contain_exactly(
          "123",
          "456",
        )
      end
    end
  end
end
