require "rails_helper"

RSpec.describe Placements::AddHostingInterestWizard::SchoolContactStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddHostingInterestWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        school: school,
        school_contact: school.school_contact,
      )
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school, with_school_contact: false) }

  describe "attributes" do
    it { is_expected.to have_attributes(first_name: nil, last_name: nil, email_address: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to allow_value("name@education.gov.uk").for(:email_address) }
    it { is_expected.to allow_value("name@example.com").for(:email_address) }
    it { is_expected.not_to allow_value("some_text").for(:email_address) }

    describe "#only_one_contact_per_school" do
      let(:first_name) { "John" }
      let(:last_name) { "Doe" }
      let(:email_address) { "joe_doe@example.com" }
      let(:attributes) { { first_name:, last_name:, email_address: } }

      context "when the school does not have a school contact" do
        it "returns valid" do
          expect(step.valid?).to be(true)
        end
      end

      context "when the school already has a school contact" do
        let(:school) { create(:placements_school) }

        context "when the school contact is the existing school contact" do
          let(:mock_wizard) do
            instance_double(Placements::EditSchoolContactWizard).tap do |mock_wizard|
              allow(mock_wizard).to receive_messages(
                school:,
                school_contact: school.school_contact,
              )
            end
          end

          it "returns valid" do
            expect(step.valid?).to be(true)
          end
        end
      end
    end
  end
end
