require "rails_helper"

RSpec.describe Placements::EditPlacementWizard do
  subject(:wizard) { described_class.new(session:, placement:, params:, school:, current_step:) }

  let(:school) { build(:placements_school, :primary, mentors:, partner_providers:) }
  let(:placement) { create(:placement, school:) }
  let(:session) { { "Placements::EditPlacementWizard" => state } }
  let(:state) { {} }
  let(:params_data) { { id: placement.id } }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:mentors) { build_list(:placements_mentor, 5) }
  let(:partner_providers) { build_list(:provider, 5) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "with the provider step" do
      let(:current_step) { :provider }

      it { is_expected.to eq %i[provider] }
    end

    context "with the mentors step" do
      let(:current_step) { :mentors }

      it { is_expected.to eq %i[mentors] }
    end

    context "with the year_group step" do
      let(:current_step) { :year_group }

      it { is_expected.to eq %i[year_group] }
    end
  end

  describe "#update_placement" do
    subject(:edit_wizard) { wizard.update_placement }

    let(:selected_mentor) { school.mentors.sample }
    let(:selected_provider) { school.partner_providers.sample }
    let(:mentor_not_known) { Placements::AddPlacementWizard::MentorsStep::NOT_KNOWN }
    let(:selected_year_group) { :year_1 }

    context "when the step is valid" do
      before { edit_wizard }

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

        context "with an unknown provider" do
          let(:state) do
            {
              "provider" => { "provider_id" => Placements::EditPlacementWizard::ProviderStep::NOT_KNOWN },
            }
          end

          it "updates the placement" do
            expect(placement.provider).to be_nil
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
