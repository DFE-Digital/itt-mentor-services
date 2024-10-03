require "rails_helper"

RSpec.describe "'Edit placement' journey", service: :placements, type: :request do
  let(:current_user) { create(:placements_user, schools: [school]) }
  let(:school) { create(:placements_school, :secondary, name: "Hogwarts", partner_providers: [provider]) }
  let(:placement) { create(:placement, school:) }
  let(:mentor) { create(:placements_mentor_membership, school:, mentor: build(:placements_mentor)).mentor }
  let(:provider) { create(:placements_provider) }
  let(:school_id) { school.id }
  let(:year_group) { :year_6 }
  let(:start_path) { new_edit_placement_placements_school_placement_path(school, placement, state_key:, step:) }
  let!(:state_key) { SecureRandom.uuid }

  before { sign_in_as current_user }

  context "when editing the mentors" do
    let(:step) { :mentors }

    context "with valid data" do
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
          expect(Placement.last.mentors).to contain_exactly(mentor)
        end

        it "redirects to the placements show page" do
          put step_path(:mentors)
          expect(response).to redirect_to placements_school_placement_path(school_id:, id: placement.id)
        end
      end
    end

    context "with invalid data" do
      before do
        put step_path(:mentors), params: { "placements_add_placement_wizard_mentors_step[mentor_ids]" => [] }
        get start_path
      end

      it "returns an error message when the mentor_ids are invalid" do
        put step_path(:mentors)

        expect(response.body).to include("Select a mentor or not yet known")
      end
    end
  end

  context "when editing the provider" do
    let(:step) { :provider }

    context "with valid data" do
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
          expect(Placement.last.provider.becomes(Placements::Provider)).to eq(provider)
        end

        it "redirects to the placements show page" do
          put step_path(:provider)
          expect(response).to redirect_to placements_school_placement_path(school_id:, id: placement.id)
        end
      end
    end

    context "with invalid data" do
      before do
        put step_path(:provider), params: { "placements_edit_placement_wizard_provider_step[provider_id]" => nil }
        get start_path
      end

      it "returns an error message when the provider_id is invalid" do
        put step_path(:provider)

        expect(response.body).to include("Select a provider")
      end
    end
  end

  context "when editing the year group" do
    let(:step) { :year_group }

    context "with valid data" do
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

    context "with invalid data" do
      before do
        put step_path(:year_group), params: { "placements_add_placement_wizard_year_group_step[year_group]" => nil }
        get start_path
      end

      it "returns an error message when the year_group is invalid" do
        put step_path(:year_group)

        expect(response.body).to include("Select a year group")
      end
    end
  end

  private

  def step_path(step)
    edit_placement_placements_school_placement_path(school_id:, id: placement, state_key:, step:)
  end
end
