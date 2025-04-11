require "rails_helper"

RSpec.describe Placements::AddHostingInterestWizard::CheckYourAnswersStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddHostingInterestWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        school:,
        steps: {
          phase: mock_phase_step,
          school_contact: mock_school_contact_step,
        },
      )
    end
  end
  let(:mock_phase_step) do
    instance_double(Placements::MultiPlacementWizard::PhaseStep).tap do |mock_phase_step|
      allow(mock_phase_step).to receive_messages(
        phases: selected_phases,
        class: Placements::MultiPlacementWizard::PhaseStep,
      )
    end
  end
  let(:mock_school_contact_step) do
    instance_double(Placements::AddHostingInterestWizard::SchoolContactStep).tap do |mock_school_contact_step|
      allow(mock_school_contact_step).to receive_messages(
        first_name:,
        last_name:,
        email_address:,
      )
    end
  end
  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }
  let(:first_name) { "Joe" }
  let(:last_name) { "Bloggs" }
  let(:email_address) { "joe_bloggs@example.com" }
  let(:selected_phases) { %w[Primary Secondary] }

  describe "delegations" do
    it { is_expected.to delegate_method(:phases).to(:phase_step) }
    it { is_expected.to delegate_method(:selected_primary_subjects).to(:wizard) }
    it { is_expected.to delegate_method(:selected_secondary_subjects).to(:wizard) }
    it { is_expected.to delegate_method(:selected_providers).to(:wizard) }
    it { is_expected.to delegate_method(:first_name).to(:school_contact_step).with_prefix(:school_contact) }
    it { is_expected.to delegate_method(:last_name).to(:school_contact_step).with_prefix(:school_contact) }
    it { is_expected.to delegate_method(:email_address).to(:school_contact_step).with_prefix(:school_contact) }
  end

  describe "#primary_and_secondary_phases?" do
    subject(:primary_and_secondary_phases) { step.primary_and_secondary_phases? }

    context "when both Primary and Secondary phases are selected" do
      it "returns true" do
        expect(primary_and_secondary_phases).to be(true)
      end
    end

    context "when only the Primary phase is selected" do
      let(:selected_phases) { %w[Primary] }

      it "returns false" do
        expect(primary_and_secondary_phases).to be(false)
      end
    end

    context "when only the Secondary phase is selected" do
      let(:selected_phases) { %w[Secondary] }

      it "returns false" do
        expect(primary_and_secondary_phases).to be(false)
      end
    end
  end
end
