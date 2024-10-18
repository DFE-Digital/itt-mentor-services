require "rails_helper"

RSpec.describe Placements::EditSchoolContactWizard do
  subject(:wizard) { described_class.new(state:, school_contact:, params:, school:, current_step:) }

  let(:school) { create(:placements_school) }
  let(:school_contact) { school.school_contact }
  let(:state) { {} }
  let(:params_data) { { id: school_contact.id } }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:current_step) { nil }

  describe "#steps" do
    subject { wizard.steps.keys }

    it { is_expected.to eq %i[school_contact] }
  end

  describe "#update_school_contact" do
    context "when the attributes passed to the steps are valid" do
      let(:first_name) { "Contacto" }
      let(:last_name) { "Escolar" }
      let(:email_address) { "updated_contact@example.com" }
      let(:state) do
        {
          "school_contact" => {
            "first_name" => first_name,
            "last_name" => last_name,
            "email_address" => email_address,
          },
        }
      end
      let(:current_step) { :school_contact }

      it "updates the school contact's attributes" do
        wizard.update_school_contact
        school_contact.reload
        expect(school_contact.first_name).to eq(first_name)
        expect(school_contact.last_name).to eq(last_name)
        expect(school_contact.email_address).to eq(email_address)
      end
    end

    context "when the email address passed is invalid" do
      let(:first_name) { "Contacto" }
      let(:last_name) { "Escolar" }
      let(:email_address) { "updated_contact" }
      let(:state) do
        {
          "school_contact" => {
            "first_name" => first_name,
            "last_name" => last_name,
            "email_address" => email_address,
          },
        }
      end
      let(:current_step) { :school_contact }

      it "raises an error" do
        expect { wizard.update_school_contact }.to raise_error "Invalid wizard state"
      end
    end

    context "when the attributes passed to the steps are invalid" do
      it "raises an error" do
        expect { wizard.update_school_contact }.to raise_error "Invalid wizard state"
      end
    end
  end

  describe "#setup_state" do
    it "returns a hash containing the school contacts attributes" do
      expect(wizard.setup_state).to eq(
        {
          "first_name" => school_contact.first_name,
          "last_name" => school_contact.last_name,
          "email_address" => school_contact.email_address,
        },
      )
    end
  end
end
