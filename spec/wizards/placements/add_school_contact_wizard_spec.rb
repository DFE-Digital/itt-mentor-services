require "rails_helper"

RSpec.describe Placements::AddSchoolContactWizard do
  subject(:wizard) { described_class.new(session:, params:, school:, current_step: nil) }

  let(:session) { { "Placements::AddSchoolContactWizard" => state } }
  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:school) { create(:placements_school, with_school_contact: false) }

  describe "#steps" do
    subject { wizard.steps.keys }

    it { is_expected.to eq %i[school_contact check_your_answers] }
  end

  describe "#create_school_contact" do
    subject(:create_school_contact) { wizard.create_school_contact }

    let(:first_name) { "John" }
    let(:last_name) { "Doe" }
    let(:email_address) { "joe_doe@example.com" }
    let(:state) do
      {
        "school_contact" => {
          "first_name" => first_name,
          "last_name" => last_name,
          "email_address" => email_address,
        },
      }
    end

    context "when the school does not have a school contact" do
      it "creates a new school contact" do
        expect { create_school_contact }.to change(
          Placements::SchoolContact, :count
        ).by(1)

        school_contact = school.school_contact
        expect(school_contact.first_name).to eq(first_name)
        expect(school_contact.last_name).to eq(last_name)
        expect(school_contact.email_address).to eq(email_address)
      end
    end

    context "when the school already has a school contact" do
      let(:school) { create(:placements_school) }

      it "returns an error" do
        expect { create_school_contact }.to raise_error("Invalid wizard state")
      end
    end
  end
end
