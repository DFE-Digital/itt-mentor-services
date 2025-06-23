require "rails_helper"

RSpec.describe Placements::PotentialPlacementHelper do
  let(:english) { create(:subject, :secondary, name: "English") }
  let(:science) { create(:subject, :secondary, name: "Science") }
  let(:key_stage_1) { create(:key_stage, name: "Key stage 1") }
  let(:mixed_key_stages) { create(:key_stage, name: "Mixed key stages") }

  describe "#potential_placement_details_viewable?" do
    subject(:potential_placement_details_viewable) do
      potential_placement_details_viewable?(placement_details)
    end

    context "when potential placements details are not present" do
      let(:placement_details) { {} }

      it "returns false" do
        expect(potential_placement_details_viewable).to be(false)
      end
    end

    context "when potential placement details include year groups" do
      let(:placement_details) do
        {
          "year_group_selection" => { "year_groups" => %w[year_2 year_3] },
        }
      end

      it "returns true" do
        expect(potential_placement_details_viewable).to be(true)
      end
    end

    context "when potential placement details include subject IDs" do
      let(:placement_details) do
        {
          "secondary_subject_selection" => { "subject_ids" => [english.id, science.id] },
        }
      end

      it "returns true" do
        expect(potential_placement_details_viewable).to be(true)
      end
    end

    context "when potential placement details include key stage IDs" do
      let(:placement_details) do
        {
          "key_stage_selection" => { "key_stage_ids" => [key_stage_1.id, mixed_key_stages.id] },
        }
      end

      it "returns true" do
        expect(potential_placement_details_viewable).to be(true)
      end
    end
  end

  describe "selected_placement_details" do
    context "when phase is primary" do
      let(:phase) { :primary }

      context "when the year groups do not contain 'unknown'" do
        let(:placement_details) do
          {
            "year_group_selection" => { "year_groups" => %w[year_2 year_3] },
          }
        end

        it "returns the selected year groups" do
          expect(
            selected_placement_details(placement_details:, phase:),
          ).to contain_exactly("year_2", "year_3")
        end
      end

      context "when the year groups do contain 'unknown'" do
        let(:placement_details) do
          {
            "year_group_selection" => { "year_groups" => %w[unknown] },
          }
        end

        it "returns unknown" do
          expect(
            selected_placement_details(placement_details:, phase:),
          ).to eq("unknown")
        end
      end
    end

    context "when phase is secondary" do
      let(:mathematics) { create(:subject, :secondary, name: "Mathematics") }

      let(:phase) { :secondary }

      context "when the subject IDs do not contain 'unknown'" do
        let(:placement_details) do
          {
            "secondary_subject_selection" => { "subject_ids" => [english.id, science.id] },
          }
        end

        it "returns the selected subjects" do
          expect(
            selected_placement_details(placement_details:, phase:),
          ).to contain_exactly(english, science)
        end
      end

      context "when the subject IDs do contain 'unknown'" do
        let(:placement_details) do
          {
            "secondary_subject_selection" => { "subject_ids" => %w[unknown] },
          }
        end

        it "returns unknown" do
          expect(
            selected_placement_details(placement_details:, phase:),
          ).to eq("unknown")
        end
      end
    end

    context "when phase is send" do
      let(:key_stage_2) { create(:key_stage, name: "Key stage 2") }

      let(:phase) { :send }

      context "when the key stage IDs do not contain 'unknown'" do
        let(:placement_details) do
          {
            "key_stage_selection" => { "key_stage_ids" => [key_stage_1.id, mixed_key_stages.id] },
          }
        end

        it "returns the selected subjects" do
          expect(
            selected_placement_details(placement_details:, phase:),
          ).to contain_exactly(key_stage_1, mixed_key_stages)
        end
      end

      context "when the key stage IDs do" do
        let(:placement_details) do
          {
            "key_stage_selection" => { "key_stage_ids" => %w[unknown] },
          }
        end

        it "returns unknown" do
          expect(
            selected_placement_details(placement_details:, phase:),
          ).to eq("unknown")
        end
      end
    end

    context "when the phase is random" do
      let(:placement_details) do
        {
          "year_group_selection" => { "year_groups" => %w[year_2 year_3] },
          "secondary_subject_selection" => { "subject_ids" => [english.id, science.id] },
          "key_stage_selection" => { "key_stage_ids" => [key_stage_1.id, mixed_key_stages.id] },
        }
      end
      let(:phase) { :random }

      it "returns an empty array" do
        expect(selected_placement_details(placement_details:, phase:)).to eq([])
      end
    end
  end

  describe "#potential_placement_year_group_selection" do
    let(:placement_details) do
      {
        "year_group_selection" => { "year_groups" => %w[year_2 year_3] },
        "secondary_subject_selection" => { "subject_ids" => [english.id, science.id] },
        "key_stage_selection" => { "key_stage_ids" => [key_stage_1.id, mixed_key_stages.id] },
      }
    end

    it "returns the selected year groups" do
      expect(potential_placement_year_group_selection(placement_details)).to contain_exactly("year_2", "year_3")
    end
  end

  describe "#potential_placement_subject_id_selection" do
    let(:placement_details) do
      {
        "year_group_selection" => { "year_groups" => %w[year_2 year_3] },
        "secondary_subject_selection" => { "subject_ids" => [english.id, science.id] },
        "key_stage_selection" => { "key_stage_ids" => [key_stage_1.id, mixed_key_stages.id] },
      }
    end

    it "returns the selected subject IDs" do
      expect(
        potential_placement_subject_id_selection(placement_details),
      ).to contain_exactly(english.id, science.id)
    end
  end

  describe "#potential_placement_key_stage_id_selection" do
    let(:placement_details) do
      {
        "year_group_selection" => { "year_groups" => %w[year_2 year_3] },
        "secondary_subject_selection" => { "subject_ids" => [english.id, science.id] },
        "key_stage_selection" => { "key_stage_ids" => [key_stage_1.id, mixed_key_stages.id] },
      }
    end

    it "returns the selected subject IDs" do
      expect(
        potential_placement_key_stage_id_selection(placement_details),
      ).to contain_exactly(key_stage_1.id, mixed_key_stages.id)
    end
  end

  describe "#placement_detail_unknown" do
    context "when the value is not unknown" do
      it "returns false" do
        expect(placement_detail_unknown("something")).to be(false)
      end
    end

    context "when the value is unknown" do
      it "returns false" do
        expect(placement_detail_unknown("unknown")).to be(true)
      end
    end
  end
end
