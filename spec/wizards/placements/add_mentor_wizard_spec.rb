require "rails_helper"

RSpec.describe Placements::AddMentorWizard do
  subject(:wizard) { described_class.new(school:, session:, params:, current_step: nil) }

  let(:session) { { "Placements::AddMentorWizard" => state } }
  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:school) { create(:placements_school) }

  describe "#steps" do
    subject { wizard.steps.keys }

    it { is_expected.to eq %i[mentor check_your_answers] }

    context "when a mentor cannot be found" do
      let(:params_data) { { trn: "1234567" } }

      before do
        mentor_step_double = instance_double(Placements::AddMentorWizard::MentorStep)
        allow(mentor_step_double).to receive(:mentor).and_return(nil)
        allow(Placements::AddMentorWizard::MentorStep).to receive(:new).and_return(mentor_step_double)
      end

      it "does not include the check your answers step" do
        expect(wizard.steps.keys).to eq %i[mentor no_results]
      end
    end
  end

  describe "#create_mentor" do
    subject(:create_mentor) { wizard.create_mentor }

    let(:trn) { "1234567" }
    let(:first_name) { "Jane" }
    let(:last_name) { "Doe" }
    let(:state) do
      {
        "mentor" => {
          "trn" => trn,
          "date_of_birth(1i)" => "2000",
          "date_of_birth(2i)" => "1",
          "date_of_birth(3i)" => "1",
        },
      }
    end

    before { stub_teaching_record_response(date_of_birth: "2000-01-01", trn:) }

    context "when the mentor does not already exist" do
      it "creates a new mentor, and a membership between the mentor and school" do
        expect { create_mentor }.to change(
          Placements::Mentor, :count
        ).by(1).and change(MentorMembership, :count).by(1)

        mentor = Placements::Mentor.find_by(trn:)
        expect(school.mentors).to contain_exactly(mentor)
      end
    end

    context "when the mentor already exists" do
      let!(:mentor) { create(:placements_mentor, first_name:, last_name:, trn:) }

      it "creates a membership between the mentor and school" do
        expect { create_mentor }.to not_change(
          Placements::Mentor, :count
        ).and change(MentorMembership, :count).by(1)

        expect(school.mentors).to contain_exactly(mentor)
      end
    end

    context "when the user and membership already exist" do
      let(:mentor) { create(:placements_mentor, first_name:, last_name:, trn:) }
      let(:membership) { create(:mentor_membership, :placements, mentor:, school:) }

      before do
        mentor
        membership
      end

      it "returns an error" do
        expect { create_mentor }.to raise_error("Invalid wizard state")
      end
    end
  end

  def stub_teaching_record_response(trn:, date_of_birth: "1991-01-22")
    allow(TeachingRecord::GetTeacher).to receive(:call).with(trn:, date_of_birth:).and_return(
      { "trn" => "1234567",
        "firstName" => "Judith",
        "lastName" => "Chicken",
        "dateOfBirth" => date_of_birth },
    )
  end
end
