require "rails_helper"

RSpec.describe "Support console / 'Edit placement' journey", service: :placements, type: :request do
  let(:current_user) { create(:placements_support_user) }
  let(:school) { create(:placements_school, :secondary, name: "Hogwarts", partner_providers: [provider]) }
  let(:placement) { create(:placement, school:) }
  let(:mentor) { create(:placements_mentor_membership, school:, mentor: build(:placements_mentor)).mentor }
  let(:provider) { create(:provider) }
  let(:school_id) { school.id }
  let(:year_group) { :year_6 }
  let(:start_path) { new_edit_placement_placements_school_placement_path(school, placement, step:) }
  let!(:state_key) { SecureRandom.uuid }

  before do
    allow(BaseWizard).to receive(:generate_state_key).and_return(state_key)
    sign_in_as current_user
  end

  context "when editing the mentors" do
    let(:step) { :mentors }

    before do
      put step_path(:mentors), params: { "placements_add_placement_wizard_mentors_step[mentor_ids]" => [mentor.id] }
      get start_path
    end

    it "redirects to the first step of the wizard" do
      expect(response).to redirect_to step_path(:mentors)
    end

    context "when the wizard is complete" do
      it "updates the placement" do
        put step_path(:mentors)
        expect(placement.mentors).to contain_exactly(mentor)
      end

      it "redirects to the placements show page" do
        put step_path(:mentors)
        expect(response).to redirect_to placements_school_placement_path(school_id:, id: placement.id)
      end
    end
  end

  context "when editing the provider" do
    let(:step) { :provider }

    before do
      put step_path(:provider), params: { "placements_edit_placement_wizard_provider_step[provider_id]" => provider.id }
      get start_path
    end

    it "redirects to the first step of the wizard" do
      expect(response).to redirect_to step_path(:provider)
    end

    context "when the wizard is complete" do
      it "updates the placement" do
        put step_path(:provider)
        expect(placement.reload.provider).to eq(provider)
      end

      it "redirects to the placements show page" do
        put step_path(:provider)
        expect(response).to redirect_to placements_school_placement_path(school_id:, id: placement.id)
      end
    end
  end

  context "when editing the year group" do
    let(:step) { :year_group }

    before do
      put step_path(:year_group), params: { "placements_add_placement_wizard_year_group_step[year_group]" => year_group }
      get start_path
    end

    it "redirects to the first step of the wizard" do
      expect(response).to redirect_to step_path(:year_group)
    end

    context "when the wizard is complete" do
      it "updates the placement" do
        put step_path(:year_group)
        expect(Placement.last.year_group).to eq("year_6")
      end

      it "redirects to the placements show page" do
        put step_path(:year_group)
        expect(response).to redirect_to placements_school_placement_path(school_id:, id: placement.id)
      end
    end
  end

  private

  def step_path(step)
    edit_placement_placements_school_placement_path(school_id:, id: placement, state_key:, step:)
  end
end
