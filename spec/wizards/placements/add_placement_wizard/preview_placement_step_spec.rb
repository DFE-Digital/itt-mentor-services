require "rails_helper"

RSpec.describe Placements::AddPlacementWizard::PreviewPlacementStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes: nil) }

  let(:mock_subject_step) { instance_double(Placements::AddPlacementWizard::SubjectStep, subject: placement_subject) }
  let(:mock_additional_subjects_step) { nil }
  let(:mock_year_group_step) { nil }
  let(:mock_mentors_step) { nil }

  let(:mock_wizard) do
    instance_double(Placements::AddPlacementWizard).tap do |wizard|
      allow(wizard).to receive_messages(school:, steps: {
        subject: mock_subject_step,
        additional_subjects: mock_additional_subjects_step,
        year_group: mock_year_group_step,
        mentors: mock_mentors_step,
      })
    end
  end

  let(:school) { create(:placements_school, phase:) }
  let(:phase) { "Primary" }
  let(:placement_subject) { create(:subject) }
  let(:additional_subjects) { [] }
  let(:year_group) { nil }
  let(:mentors) { [] }

  describe "delegations" do
    it { is_expected.to delegate_method(:school).to(:wizard) }
    it { is_expected.to delegate_method(:steps).to(:wizard) }
  end

  describe "#placement" do
    subject { step.placement }

    it { is_expected.to be_a(Placement) }
    it { is_expected.to have_attributes(subject: placement_subject) }

    context "when additional subjects are present" do
      let(:mock_additional_subjects_step) { instance_double(Placements::AddPlacementWizard::AdditionalSubjectsStep, additional_subjects:) }
      let(:additional_subjects) { create_list(:subject, 2, parent_subject: placement_subject) }

      it { is_expected.to have_attributes(additional_subjects:) }
    end

    context "when year group is present" do
      let(:mock_year_group_step) { instance_double(Placements::AddPlacementWizard::YearGroupStep, year_group:) }
      let(:year_group) { "Year 1" }

      it { is_expected.to have_attributes(year_group:) }
    end

    context "when mentors are present" do
      let(:mock_mentors_step) { instance_double(Placements::AddPlacementWizard::MentorsStep, mentors:) }
      let(:mentors) { create_list(:placements_mentor, 2) }

      it { is_expected.to have_attributes(mentors:) }
    end
  end
end
