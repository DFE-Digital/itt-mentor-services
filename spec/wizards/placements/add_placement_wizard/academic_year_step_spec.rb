require "rails_helper"

RSpec.describe Placements::AddPlacementWizard::AcademicYearStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:attributes) { nil }

  let(:mock_wizard) do
    instance_double(Placements::AddPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:steps).and_return({ subject: academic_year_step })
    end
  end

  let(:academic_year_step) do
    instance_double(described_class).tap do |academic_year_step|
      allow(academic_year_step).to receive(:academic_year_id).and_return(current_academic_year.id)
    end
  end

  let(:current_academic_year) { create(:placements_academic_year) }

  describe "attributes" do
    it { is_expected.to have_attributes(academic_year_id: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:academic_year_id) }
  end

  describe "#academic_years_for_selection" do
    let!(:current_academic_year) { Placements::AcademicYear.current }
    let!(:next_academic_year) { current_academic_year.next }
    let!(:academic_years) do
      [
        OpenStruct.new(value: current_academic_year.id, name: "This academic year (#{current_academic_year.name})"),
        OpenStruct.new(value: next_academic_year.id, name: "Next academic year (#{next_academic_year.name})"),
      ]
    end

    it "returns the current and next academic year" do
      expect(step.academic_years_for_selection).to eq(academic_years)
    end
  end
end
