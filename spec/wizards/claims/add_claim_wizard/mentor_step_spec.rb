require "rails_helper"

RSpec.describe Claims::AddClaimWizard::MentorStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::AddClaimWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(school:, mentors_with_claimable_hours: claimable_mentors)
    end
  end
  let(:school) { create(:claims_school) }
  let!(:mentor_1) { create(:claims_mentor, schools: [school]) }
  let!(:mentor_2) { create(:claims_mentor, schools: [school]) }
  let(:claimable_mentors) do
    Claims::Mentor.where(id: [mentor_1.id, mentor_2.id])
  end

  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(mentor_ids: []) }
  end

  describe "validations" do
    it { is_expected.to validate_inclusion_of(:mentor_ids).in_array(claimable_mentors.ids) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:school).to(:wizard) }
    it { is_expected.to delegate_method(:claim).to(:wizard) }
    it { is_expected.to delegate_method(:mentors_with_claimable_hours).to(:wizard) }
  end

  describe "#selected_mentors" do
    subject(:selected_mentors) { step.selected_mentors }

    let(:attributes) { { mentor_ids: [mentor_1.id, mentor_2.id] } }

    context "when there are no mentors with claimable hours with the provider" do
      let(:claimable_mentors) { nil }

      it "returns no mentors" do
        expect(selected_mentors).to eq([])
      end
    end

    context "when there are mentors with claimable hours with the provider" do
      let(:claimable_mentors) { Claims::Mentor.where(id: mentor_1.id) }

      it "returns all selected mentors" do
        expect(selected_mentors).to contain_exactly(mentor_1)
      end
    end
  end

  describe "#all_school_mentors_visible?" do
    subject(:all_school_mentors_visible) { step.all_school_mentors_visible? }

    context "when the number of members assigned to a school is the same as the number of mentors with claimable hours" do
      it "returns true" do
        expect(all_school_mentors_visible).to be(true)
      end
    end

    context "when the number of members assigned to a school is not the same as the number of mentors with claimable hours" do
      let(:claimable_mentors) do
        Claims::Mentor.where(id: mentor_1.id)
      end

      it "returns true" do
        expect(all_school_mentors_visible).to be(false)
      end
    end
  end

  describe "#mentor_ids=" do
    context "when the value is blank" do
      it "remains blank" do
        step.mentor_ids = []

        expect(step.mentor_ids).to eq([])
      end
    end

    context "when the value includes nil" do
      it "removes all values except valid mentor ids" do
        step.mentor_ids = [nil, mentor_1.id, mentor_2.id]

        expect(step.mentor_ids).to contain_exactly(mentor_1.id, mentor_2.id)
      end
    end
  end
end
