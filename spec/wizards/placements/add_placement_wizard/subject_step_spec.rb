require "rails_helper"

RSpec.describe Placements::AddPlacementWizard::SubjectStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:placement_phase).and_return(phase)
    end
  end

  let(:phase) { "Primary" }

  let(:attributes) { nil }

  let(:primary_subjects) { create_list(:subject, 5, :primary) }
  let(:secondary_subjects) { create_list(:subject, 5, :secondary) }

  let(:primary_subject_ids) { primary_subjects.map(&:id) }
  let(:secondary_subject_ids) { secondary_subjects.map(&:id) }

  describe "attributes" do
    it { is_expected.to have_attributes(subject_id: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:subject_id) }

    context "when the phase is Primary" do
      let(:phase) { "Primary" }

      it { is_expected.to validate_inclusion_of(:subject_id).in_array(primary_subject_ids) }
    end

    context "when the phase is Secondary" do
      let(:phase) { "Secondary" }

      it { is_expected.to validate_inclusion_of(:subject_id).in_array(secondary_subject_ids) }
    end
  end

  describe "#subjects_for_selection" do
    subject { step.subjects_for_selection }

    context "when the phase is Primary" do
      let(:phase) { "Primary" }

      it { is_expected.to match_array(primary_subjects) }
    end

    context "when the phase is Secondary" do
      let(:phase) { "Secondary" }

      it { is_expected.to match_array(secondary_subjects) }
    end
  end

  describe "#subject" do
    subject { step.subject }

    context "when subject_id is set" do
      let(:attributes) { { subject_id: primary_subject_ids.first } }

      it { is_expected.to eq(primary_subjects.first) }
    end

    context "when subject_id is nil" do
      let(:attributes) { { subject_id: nil } }

      it { is_expected.to be_nil }
    end
  end

  it { is_expected.to delegate_method(:name).to(:subject).with_prefix }
  it { is_expected.to delegate_method(:has_child_subjects?).to(:subject).with_prefix }
end
