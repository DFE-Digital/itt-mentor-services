RSpec.shared_examples "an 'Add mentor' journey" do
  let(:school) { create(:placements_school, :secondary, name: "Hogwarts") }
  let(:school_id) { school.id }
  let(:state_key) { SecureRandom.uuid }

  before do
    sign_in_as current_user
    allow(BaseWizard).to receive(:generate_state_key).and_return(state_key)
  end

  context "when starting a new wizard journey" do
    before do
      stub_teaching_record_response(trn: "1234567", date_of_birth: "2000-01-01")
      put step_path(:mentor), params: {
        "placements_add_mentor_wizard_mentor_step[trn]" => "1234567",
        "placements_add_mentor_wizard_mentor_step[date_of_birth(1i)]" => "2000",
        "placements_add_mentor_wizard_mentor_step[date_of_birth(2i)]" => "1",
        "placements_add_mentor_wizard_mentor_step[date_of_birth(3i)]" => "1",
      }
    end

    it "redirects to the first step of the wizard" do
      get start_path
      expect(response).to redirect_to step_path(:mentor)
    end
  end

  context "when the wizard is complete" do
    before do
      stub_teaching_record_response(trn: "1234567", date_of_birth: "2000-01-01")
      # Populate the wizard so it's ready to submit
      get start_path
      put step_path(:mentor), params: {
        "placements_add_mentor_wizard_mentor_step[trn]" => "1234567",
        "placements_add_mentor_wizard_mentor_step[date_of_birth(1i)]" => "2000",
        "placements_add_mentor_wizard_mentor_step[date_of_birth(2i)]" => "1",
        "placements_add_mentor_wizard_mentor_step[date_of_birth(3i)]" => "1",
      }
    end

    it "creates a mentor" do
      expect { put step_path(:check_your_answers) }.to change(Mentor, :count).by(1)
      expect(Mentor.last).to have_attributes({ first_name: "John", last_name: "Doe", trn: "1234567" })
    end

    it "redirects to the school's list of mentors" do
      put step_path(:check_your_answers)
      expect(response).to redirect_to placements_school_mentors_path(school_id:)
    end
  end

  private

  def stub_teaching_record_response(trn:, date_of_birth: "1991-01-22")
    allow(TeachingRecord::GetTeacher).to receive(:call).with(trn:, date_of_birth:).and_return(
      { "trn" => "1234567",
        "firstName" => "John",
        "lastName" => "Doe",
        "dateOfBirth" => date_of_birth },
    )
  end
end
