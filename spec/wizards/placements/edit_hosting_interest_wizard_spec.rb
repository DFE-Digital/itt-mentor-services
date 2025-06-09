require "rails_helper"

RSpec.describe Placements::EditHostingInterestWizard do
  subject(:wizard) do
    described_class.new(
      hosting_interest:,
      state:,
      params:,
      school:,
      current_step:,
      current_user:,
    )
  end

  let(:academic_year) { Placements::AcademicYear.current.next }
  let(:school) { create(:placements_school) }
  let(:hosting_interest) do
    create(
      :hosting_interest,
      school:,
      academic_year:,
    )
  end
  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:current_step) { nil }
  let(:current_user) { create(:placements_user) }

  describe "#steps" do
    subject(:steps) { wizard.steps.keys }

    it { is_expected.to eq %i[appetite] }

    context "when the school has existing placements" do
      context "when at least one placement is assigned to a provider" do
        before do
          create(
            :placement,
            school:,
            provider: build(:placements_provider),
            academic_year: current_user.selected_academic_year,
          )
        end

        it { is_expected.to eq %i[unable_to_change] }
      end

      context "when all placements are not assigned to providers" do
        before { create(:placement, school:, academic_year: current_user.selected_academic_year) }

        it { is_expected.to eq %i[change_placement_availability appetite] }
      end
    end

    context "when the appetite is set to 'actively_looking' during the appetite step" do
      let(:state) do
        {
          "appetite" => { "appetite" => "actively_looking" },
        }
      end

      it { is_expected.to eq %i[appetite phase check_your_answers] }

      context "when the phase is set to 'Primary' during the phase step" do
        let(:state) do
          {
            "appetite" => { "appetite" => "actively_looking" },
            "phase" => { "phases" => %w[Primary] },
          }
        end

        it {
          expect(steps).to eq(
            %i[appetite
               phase
               year_group_selection
               year_group_placement_quantity
               check_your_answers],
          )
        }
      end

      context "when the phase is set to 'Secondary' during the phase step" do
        let(:state) do
          {
            "appetite" => { "appetite" => "actively_looking" },
            "phase" => { "phases" => %w[Secondary] },
          }
        end

        it {
          expect(steps).to eq(
            %i[appetite
               phase
               secondary_subject_selection
               secondary_placement_quantity
               check_your_answers],
          )
        }

        context "when the subject selected has child subjects" do
          let(:modern_languages) { create(:subject, :secondary, name: "Modern Languages") }
          let(:french) { create(:subject, :secondary, name: "French", parent_subject: modern_languages) }
          let(:state) do
            {
              "appetite" => { "appetite" => "actively_looking" },
              "phase" => { "phases" => %w[Secondary] },
              "secondary_subject_selection" => { "subject_ids" => [modern_languages.id] },
              "secondary_placement_quantity" => { "modern_languages" => "2" },
            }
          end

          before { french }

          it {
            expect(steps).to eq(
              %i[appetite
                 phase
                 secondary_subject_selection
                 secondary_placement_quantity
                 secondary_child_subject_placement_selection_modern_languages_1
                 secondary_child_subject_placement_selection_modern_languages_2
                 check_your_answers],
            )
          }
        end
      end

      context "when the phase is set to 'Primary' and 'Secondary' during the phase step" do
        let(:state) do
          {
            "appetite" => { "appetite" => "actively_looking" },
            "phase" => { "phases" => %w[Primary Secondary] },
          }
        end

        it {
          expect(steps).to eq(
            %i[appetite
               phase
               year_group_selection
               year_group_placement_quantity
               secondary_subject_selection
               secondary_placement_quantity
               check_your_answers],
          )
        }
      end
    end

    context "when the appetite is set to 'not_open' during the appetite step" do
      let(:state) do
        {
          "appetite" => { "appetite" => "not_open" },
        }
      end

      it { is_expected.to eq %i[appetite reason_not_hosting are_you_sure] }
    end

    context "when an appetite is set to 'interested' during the appetite step" do
      let(:state) do
        {
          "appetite" => { "appetite" => "interested" },
        }
      end

      it { is_expected.to eq %i[appetite phase note_to_providers confirm] }
    end
  end

  describe "#update_hosting_interest" do
    subject(:update_hosting_interest) { wizard.update_hosting_interest }

    before { school }

    context "when the attributes passed are valid" do
      context "when the appetite is 'actively_looking'" do
        context "when the phase selected is 'Primary'" do
          let!(:primary) { create(:subject, :primary, name: "Primary", code: "00") }
          let(:state) do
            {
              "appetite" => { "appetite" => "actively_looking" },
              "phase" => { "phases" => %w[Primary] },
              "year_group_selection" => { "year_groups" => %w[reception year_3 mixed_year_groups] },
              "year_group_placement_quantity" => { "reception" => "1", "year_3" => "2", "mixed_year_groups" => "3" },
            }
          end

          it "creates hosting interest for the next academic year, assigns the appetite,
            and creates a placement for each selected subject and it's quantity" do
            expect { update_hosting_interest }.to change(Placements::HostingInterest, :count).by(1)
              .and change(Placement, :count).by(6)
            school.reload

            hosting_interest = school.hosting_interests.last
            expect(hosting_interest.appetite).to eq("actively_looking")

            primary_placements = school.placements.where(subject_id: primary.id)
            expect(primary_placements.count).to eq(6)
            expect(primary_placements.where(year_group: "reception").count).to eq(1)
            expect(primary_placements.where(year_group: "year_3").count).to eq(2)
            expect(primary_placements.where(year_group: "mixed_year_groups").count).to eq(3)
          end
        end

        context "when the phase selected is 'Secondary'" do
          let(:english) { create(:subject, :secondary, name: "English") }
          let(:mathematics) { create(:subject, :secondary, name: "Mathematics") }
          let(:state) do
            {
              "appetite" => { "appetite" => "actively_looking" },
              "phase" => { "phases" => %w[Secondary] },
              "secondary_subject_selection" => { "subject_ids" => [english.id, mathematics.id] },
              "secondary_placement_quantity" => { "english" => "2", "mathematics" => "3" },
            }
          end

          it "creates hosting interest for the next academic year, assigns the appetite,
            and creates a placement for each selected subject and it's quantity" do
            expect { update_hosting_interest }.to change(Placements::HostingInterest, :count).by(1)
              .and change(Placement, :count).by(5)
            school.reload

            hosting_interest = school.hosting_interests.last
            expect(hosting_interest.appetite).to eq("actively_looking")

            expect(school.placements.where(subject_id: english.id).count).to eq(2)
            expect(school.placements.where(subject_id: mathematics.id).count).to eq(3)
          end

          context "when a selected subject has child subjects" do
            let(:statistics) { create(:subject, :secondary, name: "Statistics", parent_subject: mathematics) }
            let(:mechanics) { create(:subject, :secondary, name: "Mechanics", parent_subject: mathematics) }
            let(:state) do
              {
                "appetite" => { "appetite" => "actively_looking" },
                "phase" => { "phases" => %w[Secondary] },
                "secondary_subject_selection" => { "subject_ids" => [english.id, mathematics.id] },
                "secondary_placement_quantity" => { "mathematics" => "2", "english" => "1" },
                "secondary_child_subject_placement_selection_mathematics_1" => {
                  "child_subject_ids" => [statistics.id, mechanics.id],
                },
                "secondary_child_subject_placement_selection_mathematics_2" => {
                  "child_subject_ids" => [statistics.id],
                },
              }
            end

            it "creates hosting interest for the next academic year, assigns the appetite,
              and creates a placement for each selected subject and it's quantity,
              plus assigning the selected child subjects" do
              expect { update_hosting_interest }.to change(Placements::HostingInterest, :count).by(1)
                .and change(Placement, :count).by(3)
              school.reload

              hosting_interest = school.hosting_interests.last
              expect(hosting_interest.appetite).to eq("actively_looking")

              expect(school.placements.where(subject_id: english.id).count).to eq(1)

              mathematics_placements = school.placements.where(subject_id: mathematics.id)
              expect(mathematics_placements.count).to eq(2)
              expect(
                mathematics_placements.map { |placement| placement.additional_subjects.pluck(:name) },
              ).to contain_exactly(%w[Statistics], %w[Statistics Mechanics])
            end
          end
        end

        context "when the phase selected is 'Primary' and 'Secondary'" do
          let!(:primary) { create(:subject, :primary, name: "Primary", code: "00") }
          let(:english) { create(:subject, :secondary, name: "English") }
          let(:mathematics) { create(:subject, :secondary, name: "Mathematics") }
          let(:state) do
            {
              "appetite" => { "appetite" => "actively_looking" },
              "phase" => { "phases" => %w[Primary Secondary] },
              "year_group_selection" => { "year_groups" => %w[reception year_3 mixed_year_groups] },
              "year_group_placement_quantity" => { "reception" => "1", "year_3" => "2", "mixed_year_groups" => "3" },
              "secondary_subject_selection" => { "subject_ids" => [english.id, mathematics.id] },
              "secondary_placement_quantity" => { "english" => "2", "mathematics" => "3" },
            }
          end

          it "creates hosting interest for the next academic year, assigns the appetite,
            creates a school contact and creates a placement for each selected subject and it's quantity" do
            expect { update_hosting_interest }.to change(Placements::HostingInterest, :count).by(1)
              .and change(Placement, :count).by(11)
            school.reload

            hosting_interest = school.hosting_interests.last
            expect(hosting_interest.appetite).to eq("actively_looking")

            primary_placements = school.placements.where(subject_id: primary.id)
            expect(primary_placements.count).to eq(6)
            expect(primary_placements.where(year_group: "reception").count).to eq(1)
            expect(primary_placements.where(year_group: "year_3").count).to eq(2)
            expect(primary_placements.where(year_group: "mixed_year_groups").count).to eq(3)

            expect(school.placements.where(subject_id: english.id).count).to eq(2)
            expect(school.placements.where(subject_id: mathematics.id).count).to eq(3)
          end
        end

        context "when the school has potential placement details" do
          let(:state) do
            {
              "appetite" => { "appetite" => "actively_looking" },
              "phase" => { "phases" => %w[Primary] },
              "year_group_selection" => { "year_groups" => %w[reception year_3 mixed_year_groups] },
              "year_group_placement_quantity" => { "reception" => "1", "year_3" => "2", "mixed_year_groups" => "3" },
            }
          end

          before do
            create(:subject, :primary, name: "Primary", code: "00")
            school.update!(
              potential_placement_details: { "appetite" => { "appetite" => "interested" } },
            )
          end

          it "nullifies the schools potential placement details" do
            expect { update_hosting_interest }.to change(school, :potential_placement_details).to(nil)
          end
        end

        context "when the school has reasons for not hosting" do
          let(:state) do
            {
              "appetite" => { "appetite" => "actively_looking" },
              "phase" => { "phases" => %w[Primary] },
              "year_group_selection" => { "year_groups" => %w[reception year_3 mixed_year_groups] },
              "year_group_placement_quantity" => { "reception" => "1", "year_3" => "2", "mixed_year_groups" => "3" },
            }
          end

          before do
            create(:subject, :primary, name: "Primary", code: "00")
            hosting_interest.update!(
              reasons_not_hosting: ["High number of pupils with SEND needs", "Other"],
              other_reason_not_hosting: "Some other reason",
            )
          end

          it "nullifies the school's reasons for not hosting" do
            expect { update_hosting_interest }.to change(hosting_interest, :reasons_not_hosting).to(nil)
              .and change(hosting_interest, :other_reason_not_hosting).to(nil)
          end
        end
      end

      context "when the appetite is 'not_open'" do
        let(:state) do
          {
            "appetite" => { "appetite" => "not_open" },
            "reason_not_hosting" => {
              "reasons_not_hosting" => [
                "Not enough trained mentors",
                "Number of pupils with SEND needs",
                "Working to improve our OFSTED rating",
              ],
            },
          }
        end

        context "when school has no hosting interest for the next academic year" do
          let(:school) { create(:placements_school, with_school_contact: false) }

          it "creates hosting interest for the next academic year, assigns the appetite,
            and reasons not hosting" do
            expect { update_hosting_interest }.to change(Placements::HostingInterest, :count).by(1)
            school.reload

            hosting_interest = school.hosting_interests.last
            expect(hosting_interest.appetite).to eq("not_open")
            expect(hosting_interest.reasons_not_hosting).to contain_exactly(
              "Not enough trained mentors",
              "Number of pupils with SEND needs",
              "Working to improve our OFSTED rating",
            )
          end
        end

        context "when the school has potential placement details" do
          before do
            school.update!(
              potential_placement_details: { "appetite" => { "appetite" => "interested" } },
            )
          end

          it "nullifies the schools potential placement details" do
            expect { update_hosting_interest }.to change(school, :potential_placement_details).to(nil)
          end
        end

        context "when the school has existing placements" do
          before { create(:placement, school:, academic_year: current_user.selected_academic_year) }

          it "destroys all the placements for that school in the selected academic year" do
            expect { update_hosting_interest }.to change {
              school.placements.available_placements_for_academic_year(
                current_user.selected_academic_year,
              ).count
            }.from(1).to(0)
          end
        end
      end

      context "when the appetite is 'interested'" do
        context "when the phase is unknown" do
          let(:state) do
            {
              "appetite" => { "appetite" => "interested" },
              "phase" => { "phases" => %w[unknown] },
              "note_to_providers" => { "note" => "" },
            }
          end

          it "updates the schools potential placement details" do
            expect { update_hosting_interest }.to change(school, :potential_placement_details).from(nil)
            school.reload
            potential_placement_details = school.potential_placement_details
            expect(potential_placement_details["phase"]).to eq({ "phases" => %w[unknown] })
            expect(potential_placement_details["note_to_providers"]).to eq({ "note" => "" })
          end
        end

        context "when the school has existing placements" do
          let(:state) do
            {
              "appetite" => { "appetite" => "interested" },
              "phase" => { "phases" => %w[unknown] },
              "note_to_providers" => { "note" => "" },
            }
          end

          before { create(:placement, school:, academic_year: current_user.selected_academic_year) }

          it "destroys all the placements for that school in the selected academic year" do
            expect { update_hosting_interest }.to change {
              school.placements.available_placements_for_academic_year(
                current_user.selected_academic_year,
              ).count
            }.from(1).to(0)
          end
        end

        context "when the school has reasons for not hosting" do
          let(:state) do
            {
              "appetite" => { "appetite" => "interested" },
              "phase" => { "phases" => %w[unknown] },
              "note_to_providers" => { "note" => "" },
            }
          end

          before do
            hosting_interest.update!(
              reasons_not_hosting: ["High number of pupils with SEND needs", "Other"],
              other_reason_not_hosting: "Some other reason",
            )
          end

          it "nullifies the school's reasons for not hosting" do
            expect { update_hosting_interest }.to change(hosting_interest, :reasons_not_hosting).to(nil)
              .and change(hosting_interest, :other_reason_not_hosting).to(nil)
          end
        end
      end

      context "when a step is invalid" do
        let(:state) do
          {
            "appetite" => { "appetite" => "blah" },
            "reason_not_hosting" => {
              "reasons_not_hosting" => [
                "Not enough trained mentors",
                "Number of pupils with SEND needs",
                "Working to improve our OFSTED rating",
              ],
            },
          }
        end

        it "returns an error" do
          expect { update_hosting_interest }.to raise_error "Invalid wizard state"
        end
      end
    end
  end

  describe "#setup_state" do
    subject(:setup_state) { wizard.setup_state }

    context "when the school has a hosting interest for the next academic year" do
      let(:school) { create(:placements_school) }
      let(:hosting_interest) do
        create(:hosting_interest,
               school:,
               academic_year: Placements::AcademicYear.current.next,
               appetite: "not_open",
               reasons_not_hosting: [
                 "Not enough trained mentors",
                 "Number of pupils with SEND needs",
               ],
               other_reason_not_hosting: "Some reason")
      end

      before { hosting_interest }

      it "returns a hash containing the attributes for the schools hosting interest" do
        setup_state
        expect(state).to eq(
          {
            "appetite" => { "appetite" => "not_open" },
            "reason_not_hosting" => {
              "reasons_not_hosting" => [
                "Not enough trained mentors", "Number of pupils with SEND needs"
              ],
              "other_reason_not_hosting" => "Some reason",
            },
          },
        )
      end
    end
  end
end
