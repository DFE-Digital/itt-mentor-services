require "rails_helper"

RSpec.describe Placements::AddHostingInterestWizard::ReasonNotHostingStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddHostingInterestWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }

  describe "attributes" do
    it { is_expected.to have_attributes(reasons_not_hosting: [], other_reason_not_hosting: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:reasons_not_hosting) }
    it { is_expected.not_to validate_presence_of(:other_reason_not_hosting) }

    context "when the 'reasons_not_hosting' is 'Other'" do
      context "when" do
        let(:attributes) { { reasons_not_hosting: %w[Other], other_reason_not_hosting: nil } }

        it { is_expected.to validate_presence_of(:other_reason_not_hosting) }
      end
    end
  end

  describe "#reason_options" do
    subject(:reason_options) { step.reason_options }

    it "returns struct objects for each reason not to host ITT" do
      high_number_of_pupils_with_send_needs = reason_options[0]
      low_capacity_to_support_trainees_due_to_staff_changes = reason_options[1]
      no_mentors_available_due_to_capacity = reason_options[2]
      concerns_about_trainee_quality = reason_options[3]
      unsure_how_to_get_involved = reason_options[4]
      working_to_improve_our_ofsted_rating = reason_options[5]
      other = reason_options[6]

      expect(high_number_of_pupils_with_send_needs.name).to eq("High number of pupils with SEND needs")
      expect(high_number_of_pupils_with_send_needs.value).to eq("High number of pupils with SEND needs")

      expect(low_capacity_to_support_trainees_due_to_staff_changes.name).to eq(
        "Low capacity to support trainees due to staff changes",
      )
      expect(low_capacity_to_support_trainees_due_to_staff_changes.value).to eq(
        "Low capacity to support trainees due to staff changes",
      )

      expect(no_mentors_available_due_to_capacity.name).to eq(
        "No mentors available due to capacity",
      )
      expect(no_mentors_available_due_to_capacity.value).to eq(
        "No mentors available due to capacity",
      )

      expect(concerns_about_trainee_quality.name).to eq("Trainees we were offered did not meet our expectations")
      expect(concerns_about_trainee_quality.value).to eq("Trainees we were offered did not meet our expectations")

      expect(unsure_how_to_get_involved.name).to eq("Unsure how to get involved")
      expect(unsure_how_to_get_involved.value).to eq("Unsure how to get involved")

      expect(working_to_improve_our_ofsted_rating.name).to eq("Working to improve our OFSTED rating")
      expect(working_to_improve_our_ofsted_rating.value).to eq("Working to improve our OFSTED rating")

      expect(other.name).to eq("Other")
      expect(other.value).to eq("Other")
    end
  end

  describe "#reasons_not_hosting" do
    subject(:reasons_not_hosting) { step.reasons_not_hosting }

    context "when reasons_not_hosting is blank" do
      it "returns an empty array" do
        expect(reasons_not_hosting).to eq([])
      end
    end

    context "when the reasons_not_hosting attribute contains a blank element" do
      let(:attributes) { { reasons_not_hosting: ["Number of pupils with SEND needs", nil] } }

      it "removes the nil element from the reasons_not_hosting attribute" do
        expect(reasons_not_hosting).to contain_exactly("Number of pupils with SEND needs")
      end
    end

    context "when the reasons_not_hosting attribute contains no blank elements" do
      let(:attributes) { { reasons_not_hosting: ["Not enough trained mentors", "Number of pupils with SEND needs"] } }

      it "returns the reasons_not_hosting attribute unchanged" do
        expect(reasons_not_hosting).to contain_exactly(
          "Not enough trained mentors",
          "Number of pupils with SEND needs",
        )
      end
    end
  end
end
