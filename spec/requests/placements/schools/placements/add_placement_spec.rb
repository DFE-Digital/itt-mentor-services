require "rails_helper"

RSpec.describe "'Add placement' journey", service: :placements, type: :request do
  let(:current_user) { create(:placements_user, schools: [school]) }
  let(:school) { create(:placements_school, :secondary, name: "Hogwarts") }
  let(:school_id) { school.id }
  let(:current_academic_year) { create(:placements_academic_year) }
  let(:drama) { create(:subject, :secondary, name: "Drama") }
  let(:summer_term) { create(:placements_term, :summer) }
  let(:start_path) { new_add_placement_placements_school_placements_path(school_id:) }

  before { sign_in_as current_user }

  context "when starting a new wizard journey" do
    before do
      # Populate the wizard so it has some existing state
      put step_path(:subject), params: { "placements_add_placement_wizard_subject_step[subject_id]" => drama.id }
      put step_path(:academic_year), params: { "placements_add_placement_wizard_academic_year_step[academic_year_id]" => current_academic_year.id }
      put step_path(:terms), params: { "placements_add_placement_wizard_terms_step[term_ids]" => [summer_term.id] }
    end

    it "resets the wizard state" do
      expect(request.session["Placements::AddPlacementWizard"]).to be_present
      get start_path
      expect(request.session["Placements::AddPlacementWizard"]).to be_empty
    end

    it "redirects to the first step of the wizard" do
      get start_path
      expect(response).to redirect_to step_path(:subject)
    end
  end

  context "when the wizard is complete" do
    before do
      # Populate the wizard so it's ready to submit
      get start_path
      put step_path(:subject), params: {
        "placements_add_placement_wizard_subject_step[subject_id]" => drama.id,
      }
      put step_path(:academic_year), params: {
        "placements_add_placement_wizard_academic_year_step[academic_year_id]" => current_academic_year.id,
      }
      put step_path(:terms), params: { "placements_add_placement_wizard_terms_step[term_ids]" => [summer_term.id] }
    end

    it "creates a placement" do
      expect { put step_path(:check_your_answers) }.to change(Placement, :count).by(1)
      expect(Placement.last).to have_attributes({ school:, subject: drama })
    end

    it "sends a Slack message" do
      expect { put step_path(:check_your_answers) }
      .to have_enqueued_job(SlackNotifier::Message::DeliveryJob)
      .with(anything, ":new: Placement added: Drama at Hogwarts", anything)
    end

    it "resets the wizard state" do
      expect(request.session["Placements::AddPlacementWizard"]).to be_present
      put step_path(:check_your_answers)
      expect(request.session["Placements::AddPlacementWizard"]).to be_empty
    end

    it "redirects to the school's list of placements" do
      put step_path(:check_your_answers)
      expect(response).to redirect_to placements_school_placements_path(school_id:)
    end
  end

  describe "unhappy paths" do
    let(:test_paths) do
      [
        start_path,
        step_path(:subject),
        step_path(:check_your_answers),
      ]
    end

    context "when the user does not belong to the school" do
      let(:current_user) { create(:placements_user) }

      it "raises an error" do
        test_paths.each do |path|
          expect { get path }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    context "when the school doesn't have a placement contact" do
      let(:school) { create(:placements_school, with_school_contact: false) }

      it "redirects to the homepage with an error message" do
        test_paths.each do |path|
          get path
          expect(response).to redirect_to(placements_root_url)
          expect(flash[:heading]).to eq("You cannot perform this action")
          expect(flash[:success]).to be false
        end
      end
    end
  end

  private

  def step_path(step)
    add_placement_placements_school_placements_path(school_id:, step:)
  end
end
