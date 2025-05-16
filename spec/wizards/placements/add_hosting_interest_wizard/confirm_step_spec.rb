require "rails_helper"

RSpec.describe Placements::AddHostingInterestWizard::ConfirmStep, type: :model do
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
  let(:mock_note_to_providers_step) do
    instance_double(Placements::AddHostingInterestWizard::NoteToProvidersStep).tap do |mock_note_to_providers_step|
      allow(mock_note_to_providers_step).to receive_messages(
        note:,
      )
    end
  end
  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }
  let(:first_name) { "Joe" }
  let(:last_name) { "Bloggs" }
  let(:email_address) { "joe_bloggs@example.com" }
  let(:selected_phases) { %w[Primary Secondary] }
  let(:note) { nil }

  describe "delegations" do
    it { is_expected.to delegate_method(:phases).to(:phase_step) }
    it { is_expected.to delegate_method(:year_groups).to(:wizard) }
    it { is_expected.to delegate_method(:selected_secondary_subjects).to(:wizard) }
    it { is_expected.to delegate_method(:selected_providers).to(:wizard) }
    it { is_expected.to delegate_method(:sen_quantity).to(:wizard) }
    it { is_expected.to delegate_method(:selected_key_stages).to(:wizard) }
    it { is_expected.to delegate_method(:first_name).to(:school_contact_step).with_prefix(:school_contact) }
    it { is_expected.to delegate_method(:last_name).to(:school_contact_step).with_prefix(:school_contact) }
    it { is_expected.to delegate_method(:email_address).to(:school_contact_step).with_prefix(:school_contact) }
    it { is_expected.to delegate_method(:note).to(:note_to_providers_step) }
  end
end
