require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::ReasonNotHostingStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }

  describe "attributes" do
    it { is_expected.to have_attributes(reasons_not_hosting: []) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:reasons_not_hosting) }
  end

  describe "#reason_options" do
    subject(:reason_options) { step.reason_options }

    it "returns struct objects for each reason not to host ITT" do
      not_enough_trained_mentors = reason_options[0]
      number_of_pupils_with_send_needs = reason_options[1]
      working_to_improve_our_ofsted_rating = reason_options[2]

      expect(not_enough_trained_mentors.name).to eq("Not enough trained mentors")
      expect(not_enough_trained_mentors.value).to eq("Not enough trained mentors")

      expect(number_of_pupils_with_send_needs.name).to eq("Number of pupils with SEND needs")
      expect(number_of_pupils_with_send_needs.value).to eq("Number of pupils with SEND needs")

      expect(working_to_improve_our_ofsted_rating.name).to eq("Working to improve our OFSTED rating")
      expect(working_to_improve_our_ofsted_rating.value).to eq("Working to improve our OFSTED rating")
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
