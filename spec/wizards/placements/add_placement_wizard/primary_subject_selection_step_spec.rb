require "rails_helper"

RSpec.describe Placements::AddPlacementWizard::PrimarySubjectSelectionStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:placement_phase).and_return(phase)
    end
  end

  let(:phase) { "Primary" }

  let(:attributes) { nil }

  let(:primary_subjects) { create_list(:subject, 5, :primary) }

  let(:primary_subject_ids) { primary_subjects.map(&:id) }

  describe "attributes" do
    it { is_expected.to have_attributes(subject_id: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:subject_id) }

    it { is_expected.to validate_inclusion_of(:subject_id).in_array(primary_subject_ids) }
  end

  describe "#subjects_for_selection" do
    subject { step.subjects_for_selection }

    it { is_expected.to match_array(primary_subjects) }
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
