require "rails_helper"

RSpec.describe Placements::EditHostingInterestWizard::UnableToChangeStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::EditHostingInterestWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        school:,
        current_user:,
      )
    end
  end

  let(:attributes) { nil }
  let(:school) { create(:placements_school) }
  let(:current_user) { create(:placements_user, schools: [school]) }
  let(:hosting_interest) { create(:hosting_interest, school:) }
  let(:assigned_school_placements) do
    create_list(
      :placement,
      3,
      school:,
      provider: build(:placements_provider),
      academic_year: current_user.selected_academic_year,
    )
  end
  let(:unassigned_school_placements) { create_list(:placement, 3, school:) }
  let(:unavailable_placements) { Placement.where(id: assigned_school_placements.pluck(:id)) }

  describe "delegations" do
    it { is_expected.to delegate_method(:school).to(:wizard) }
    it { is_expected.to delegate_method(:current_user).to(:wizard) }
    it { is_expected.to delegate_method(:placements).to(:school) }
  end

  describe "#assigned_placements" do
    subject(:assigned_placements) { step.assigned_placements }

    before do
      assigned_school_placements
      unassigned_school_placements
    end

    it "returns assigned pathways decorated" do
      expect(assigned_placements).to match_array(
        unavailable_placements.decorate,
      )
    end
  end
end
