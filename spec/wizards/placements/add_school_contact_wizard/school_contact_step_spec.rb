require "rails_helper"

RSpec.describe Placements::AddSchoolContactWizard::SchoolContactStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::AddSchoolContactWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end
  let(:school) { create(:placements_school, with_school_contact: false) }
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(first_name: nil, last_name: nil, email_address: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to allow_value("name@education.gov.uk").for(:email_address) }
    it { is_expected.to allow_value("name@example.com").for(:email_address) }
    it { is_expected.not_to allow_value("some_text").for(:email_address) }

    describe "#new_school_contact" do
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

        it "returns invalid" do
          expect(step.valid?).to be(false)
        end
      end
    end

    describe "#school_contact" do
      let(:first_name) { "John" }
      let(:last_name) { "Doe" }
      let(:email_address) { "joe_doe@example.com" }
      let(:attributes) { { first_name:, last_name:, email_address: } }

      it "returns a new school contact record for the school" do
        school_contact = step.school_contact
        expect(school_contact.new_record?).to be(true)
        expect(school_contact.school).to eq(school)
        expect(school_contact.first_name).to eq(first_name)
        expect(school_contact.last_name).to eq(last_name)
        expect(school_contact.email_address).to eq(email_address)
      end
    end
  end
end
