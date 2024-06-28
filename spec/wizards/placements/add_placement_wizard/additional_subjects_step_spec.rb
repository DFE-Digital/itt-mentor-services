require "rails_helper"

RSpec.describe Placements::AddPlacementWizard::AdditionalSubjectsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:steps).and_return({ subject: subject_step })
    end
  end

  let(:subject_step) do
    instance_double(Placements::AddPlacementWizard::SubjectStep).tap do |subject_step|
      allow(subject_step).to receive(:subject_id).and_return(modern_foreign_languages.id)
    end
  end

  let(:attributes) { nil }

  let(:modern_foreign_languages) { create(:subject, :secondary, child_subjects: [french, german]) }
  let(:french) { build(:subject, :secondary, name: "French") }
  let(:german) { build(:subject, :secondary, name: "German") }
  let(:drama) { create(:subject, :secondary, name: "Drama") }

  describe "attributes" do
    it { is_expected.to have_attributes(additional_subject_ids: []) }
  end

  describe "validations" do
    context "when the additional subjects are children of the parent subject" do
      let(:attributes) { { additional_subject_ids: [french.id, german.id] } }

      it { is_expected.to be_valid }
    end

    context "when the additional subjects are blank" do
      let(:attributes) { { additional_subject_ids: [] } }

      it { is_expected.to be_invalid }
    end

    context "when the additional subjects are NOT all children of the parent subject" do
      let(:attributes) { { additional_subject_ids: [french.id, german.id, drama.id] } }

      it { is_expected.to be_invalid }
    end

    context "when the additional subjects are not actual subject IDs" do
      let(:attributes) { { additional_subject_ids: ["not a real subject ID"] } }

      it { is_expected.to be_invalid }
    end
  end

  describe "#additional_subjects_for_selection" do
    it "returns child subjects of the parent subject" do
      expect(step.additional_subjects_for_selection).to eq([french, german])
    end
  end
end
