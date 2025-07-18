require "rails_helper"

RSpec.describe Placements::EditPlacementWizard do
  subject(:wizard) { described_class.new(state:, placement:, params:, school:, current_step:, current_user:) }

  let(:school) { build(:placements_school, :primary, mentors:, partner_providers:) }
  let(:placement) { create(:placement, school:, academic_year: current_user.selected_academic_year) }
  let(:state) { {} }
  let(:params_data) { { id: placement.id } }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:mentors) { build_list(:placements_mentor, 5) }
  let(:partner_providers) { build_list(:provider, 5) }
  let(:current_user) { create(:placements_user, schools: [school]) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "with the provider step" do
      let(:current_step) { :provider }

      context "when provider is set in the provider step" do
        let(:provider) { create(:provider) }
        let(:state) do
          {
            "provider" => {
              "provider_id" => provider.id,
            },
          }
        end

        it { is_expected.to eq %i[provider assign_last_placement] }
      end

      context "when provider id is not set in the provider step" do
        it { is_expected.to eq %i[provider provider_options assign_last_placement] }
      end

      context "when the this placement is not the last unassigned placement" do
        before { create(:placement, school:, academic_year: current_user.selected_academic_year) }

        it { is_expected.to eq %i[provider provider_options] }
      end
    end

    context "with the mentors step" do
      let(:current_step) { :mentors }

      it { is_expected.to eq %i[mentors] }
    end

    context "with the year_group step" do
      let(:current_step) { :year_group }

      it { is_expected.to eq %i[year_group] }
    end

    context "with the terms step" do
      let(:current_step) { :terms }

      it { is_expected.to eq %i[terms] }
    end

    context "with the key stage step" do
      let(:current_step) { :key_stage }

      it { is_expected.to eq %i[key_stage] }
    end
  end

  describe "#update_placement" do
    subject(:edit_wizard) { wizard.update_placement }

    let(:selected_mentor) { school.mentors.sample }
    let(:selected_provider) { school.partner_providers.sample }
    let(:mentor_not_known) { Placements::AddPlacementWizard::MentorsStep::NOT_KNOWN }
    let(:selected_year_group) { :year_1 }
    let(:selected_term) { create(:placements_term, :summer) }
    let(:key_stage_1) { create(:key_stage, name: "Key stage 1") }

    context "when the step is valid" do
      before do
        selected_term
        key_stage_1
        _spring_term = create(:placements_term, :spring)
        _autumn_term = create(:placements_term, :autumn)
        edit_wizard
      end

      context "when the step is mentors" do
        let(:current_step) { :mentors }

        context "with an existing mentor" do
          let(:state) do
            {
              "mentors" => { "mentor_ids" => [selected_mentor.id] },
            }
          end

          it "updates the placement" do
            expect(placement.mentors).to eq [selected_mentor]
          end
        end

        context "with an unknown mentor" do
          let(:state) do
            {
              "mentors" => { "mentor_ids" => mentor_not_known },
            }
          end

          it "updates the placement" do
            expect(placement.mentors).to eq []
          end
        end
      end

      context "when the step is provider" do
        let(:current_step) { :provider }

        context "with an existing provider" do
          let(:state) do
            {
              "provider" => { "provider_id" => selected_provider.id },
            }
          end

          it "updates the placement" do
            expect(placement.provider).to eq selected_provider
          end
        end
      end

      context "when the step is provider options" do
        let(:current_step) { :provider_options }

        context "with an existing provider" do
          let(:state) do
            {
              "provider" => { "provider_id" => selected_provider.name },
              "provider_options" => { "provider_id" => selected_provider.id },
            }
          end

          it "updates the placement" do
            expect(placement.provider).to eq selected_provider
          end
        end
      end

      context "when the step is year_group" do
        let(:current_step) { :year_group }
        let(:state) do
          {
            "year_group" => { "year_group" => selected_year_group },
          }
        end

        it "updates the placement" do
          expect(placement.year_group).to eq "year_1"
        end
      end

      context "when the step is terms" do
        let(:current_step) { :terms }

        let(:state) do
          {
            "terms" => { "term_ids" => [selected_term.id] },
          }
        end

        it "updates the placement" do
          expect(placement.terms).to contain_exactly(selected_term)
        end
      end

      context "when the step is key stage" do
        let(:current_step) { :key_stage }

        let(:state) do
          {
            "key_stage" => { "key_stage_id" => key_stage_1.id },
          }
        end

        it "updates the placement" do
          expect(placement.key_stage).to eq(key_stage_1)
        end
      end
    end

    context "when a step is invalid" do
      let(:current_step) { :mentors }
      let(:state) do
        {
          "mentors" => { "mentor_ids" => [] }, # invalid
        }
      end

      it "raises an error" do
        expect { wizard.update_placement }.to raise_error "Invalid wizard state"
      end
    end
  end
end
