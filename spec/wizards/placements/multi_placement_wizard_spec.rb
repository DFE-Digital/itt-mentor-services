require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard do
  subject(:wizard) { described_class.new(state:, params:, school:, current_step:) }

  let(:school) { create(:placements_school) }
  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:current_step) { nil }

  describe "#steps" do
    subject(:steps) { wizard.steps.keys }

    it { is_expected.to eq %i[appetite school_contact] }

    context "when the appetite is set to 'actively_looking' during the appetite step" do
      let(:state) do
        {
          "appetite" => { "appetite" => "actively_looking" },
        }
      end

      it { is_expected.to eq %i[appetite phase provider school_contact check_your_answers] }

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
               primary_subject_selection
               primary_placement_quantity
               provider
               school_contact
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
               provider
               school_contact
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
                 provider
                 school_contact
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
               primary_subject_selection
               primary_placement_quantity
               secondary_subject_selection
               secondary_placement_quantity
               provider
               school_contact
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

      it { is_expected.to eq %i[appetite reason_not_hosting school_contact are_you_sure] }
    end

    context "when an appetite is set to 'interested' during the appetite step" do
      let(:state) do
        {
          "appetite" => { "appetite" => "interested" },
        }
      end

      it { is_expected.to eq %i[appetite school_contact confirm] }
    end
  end

  describe "#update_school_placements" do
    subject(:update_school_placements) { wizard.update_school_placements }

    before { school }

    context "when the attributes passed are valid" do
      context "when the appetite is 'actively_looking'" do
        context "when the phase selected is 'Primary'" do
          let(:primary_with_english) { create(:subject, :primary, name: "Primary with english") }
          let(:primary_with_science) { create(:subject, :primary, name: "Primary with science") }
          let(:state) do
            {
              "appetite" => { "appetite" => "actively_looking" },
              "phase" => { "phases" => %w[Primary] },
              "primary_subject_selection" => { "subject_ids" => [primary_with_english.id, primary_with_science.id] },
              "primary_placement_quantity" => { "primary_with_english" => "1", "primary_with_science" => "2" },
              "school_contact" => {
                "first_name" => "Joe",
                "last_name" => "Bloggs",
                "email_address" => "joe_bloggs@example.com",
              },
            }
          end

          it "creates hosting interest for the next academic year, assigns the appetite,
            creates a school contact and creates a placement for each selected subject and it's quantity" do
            expect { update_school_placements }.to change(Placements::HostingInterest, :count).by(1)
              .and change(Placement, :count).by(3)
            school.reload

            hosting_interest = school.hosting_interests.last
            expect(hosting_interest.appetite).to eq("actively_looking")

            expect(school.placements.where(subject_id: primary_with_english.id).count).to eq(1)
            expect(school.placements.where(subject_id: primary_with_science.id).count).to eq(2)

            school_contact = school.school_contact
            expect(school_contact.first_name).to eq("Joe")
            expect(school_contact.last_name).to eq("Bloggs")
            expect(school_contact.email_address).to eq("joe_bloggs@example.com")
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
              "school_contact" => {
                "first_name" => "Joe",
                "last_name" => "Bloggs",
                "email_address" => "joe_bloggs@example.com",
              },
            }
          end

          it "creates hosting interest for the next academic year, assigns the appetite,
            creates a school contact and creates a placement for each selected subject and it's quantity" do
            expect { update_school_placements }.to change(Placements::HostingInterest, :count).by(1)
              .and change(Placement, :count).by(5)
            school.reload

            hosting_interest = school.hosting_interests.last
            expect(hosting_interest.appetite).to eq("actively_looking")

            expect(school.placements.where(subject_id: english.id).count).to eq(2)
            expect(school.placements.where(subject_id: mathematics.id).count).to eq(3)

            school_contact = school.school_contact
            expect(school_contact.first_name).to eq("Joe")
            expect(school_contact.last_name).to eq("Bloggs")
            expect(school_contact.email_address).to eq("joe_bloggs@example.com")
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
                "school_contact" => {
                  "first_name" => "Joe",
                  "last_name" => "Bloggs",
                  "email_address" => "joe_bloggs@example.com",
                },
              }
            end

            it "creates hosting interest for the next academic year, assigns the appetite,
              creates a school contact and creates a placement for each selected subject and it's quantity,
              plus assigning the selected child subjects" do
              expect { update_school_placements }.to change(Placements::HostingInterest, :count).by(1)
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

              school_contact = school.school_contact
              expect(school_contact.first_name).to eq("Joe")
              expect(school_contact.last_name).to eq("Bloggs")
              expect(school_contact.email_address).to eq("joe_bloggs@example.com")
            end
          end
        end

        context "when the phase selected is 'Primary' and 'Secondary'" do
          let(:primary_with_english) { create(:subject, :primary, name: "Primary with english") }
          let(:primary_with_science) { create(:subject, :primary, name: "Primary with science") }
          let(:english) { create(:subject, :secondary, name: "English") }
          let(:mathematics) { create(:subject, :secondary, name: "Mathematics") }
          let(:state) do
            {
              "appetite" => { "appetite" => "actively_looking" },
              "phase" => { "phases" => %w[Primary Secondary] },
              "primary_subject_selection" => { "subject_ids" => [primary_with_english.id, primary_with_science.id] },
              "primary_placement_quantity" => { "primary_with_english" => "1", "primary_with_science" => "2" },
              "secondary_subject_selection" => { "subject_ids" => [english.id, mathematics.id] },
              "secondary_placement_quantity" => { "english" => "2", "mathematics" => "3" },
              "school_contact" => {
                "first_name" => "Joe",
                "last_name" => "Bloggs",
                "email_address" => "joe_bloggs@example.com",
              },
            }
          end

          it "creates hosting interest for the next academic year, assigns the appetite,
            creates a school contact and creates a placement for each selected subject and it's quantity" do
            expect { update_school_placements }.to change(Placements::HostingInterest, :count).by(1)
              .and change(Placement, :count).by(8)
            school.reload

            hosting_interest = school.hosting_interests.last
            expect(hosting_interest.appetite).to eq("actively_looking")

            expect(school.placements.where(subject_id: primary_with_english.id).count).to eq(1)
            expect(school.placements.where(subject_id: primary_with_science.id).count).to eq(2)
            expect(school.placements.where(subject_id: english.id).count).to eq(2)
            expect(school.placements.where(subject_id: mathematics.id).count).to eq(3)

            school_contact = school.school_contact
            expect(school_contact.first_name).to eq("Joe")
            expect(school_contact.last_name).to eq("Bloggs")
            expect(school_contact.email_address).to eq("joe_bloggs@example.com")
          end

          context "when provider_ids is set to 'select_all'" do
            let(:state) do
              {
                "appetite" => { "appetite" => "actively_looking" },
                "phase" => { "phases" => %w[Primary Secondary] },
                "primary_subject_selection" => { "subject_ids" => [primary_with_english.id] },
                "primary_placement_quantity" => { "primary_with_english" => "1" },
                "secondary_subject_selection" => { "subject_ids" => [english.id] },
                "secondary_placement_quantity" => { "english" => "1" },
                "provider" => { "provider_ids" => %w[select_all] },
                "school_contact" => {
                  "first_name" => "Joe",
                  "last_name" => "Bloggs",
                  "email_address" => "joe_bloggs@example.com",
                },
              }
            end
            let(:test_provider_1) { create(:provider, name: "Test Provider 123") }
            let(:test_provider_2) { create(:provider, name: "Test Provider 456") }
            let(:test_provider_3) { create(:provider, name: "Test Provider 789") }

            before do
              test_provider_1
              test_provider_2
              test_provider_3
            end

            it "creates hosting interest for the next academic year, assigns the appetite,
              creates a school contact and creates a placement for each selected subject and it's quantity
              and create partnerships with all test providers" do
              expect { update_school_placements }.to change(Placements::HostingInterest, :count).by(1)
                .and change(Placement, :count).by(2)
                .and change(Placements::Partnership, :count).by(3)
              school.reload

              hosting_interest = school.hosting_interests.last
              expect(hosting_interest.appetite).to eq("actively_looking")

              expect(school.placements.where(subject_id: primary_with_english.id).count).to eq(1)
              expect(school.placements.where(subject_id: english.id).count).to eq(1)

              expect(school.partner_providers).to contain_exactly(
                test_provider_1,
                test_provider_2,
                test_provider_3,
              )

              school_contact = school.school_contact
              expect(school_contact.first_name).to eq("Joe")
              expect(school_contact.last_name).to eq("Bloggs")
              expect(school_contact.email_address).to eq("joe_bloggs@example.com")
            end
          end

          context "when provider_ids is contains specific provider ids" do
            let(:state) do
              {
                "appetite" => { "appetite" => "actively_looking" },
                "phase" => { "phases" => %w[Primary Secondary] },
                "primary_subject_selection" => { "subject_ids" => [primary_with_english.id] },
                "primary_placement_quantity" => { "primary_with_english" => "1" },
                "secondary_subject_selection" => { "subject_ids" => [english.id] },
                "secondary_placement_quantity" => { "english" => "1" },
                "provider" => { "provider_ids" => [test_provider_1.id, test_provider_3.id] },
                "school_contact" => {
                  "first_name" => "Joe",
                  "last_name" => "Bloggs",
                  "email_address" => "joe_bloggs@example.com",
                },
              }
            end
            let(:test_provider_1) { create(:provider, name: "Test Provider 123") }
            let(:test_provider_2) { create(:provider, name: "Test Provider 456") }
            let(:test_provider_3) { create(:provider, name: "Test Provider 789") }

            before do
              test_provider_1
              test_provider_2
              test_provider_3
            end

            it "creates hosting interest for the next academic year, assigns the appetite,
              creates a school contact and creates a placement for each selected subject and it's quantity
              and create partnerships for the selected test providers" do
              expect { update_school_placements }.to change(Placements::HostingInterest, :count).by(1)
                .and change(Placement, :count).by(2)
                .and change(Placements::Partnership, :count).by(2)
              school.reload

              hosting_interest = school.hosting_interests.last
              expect(hosting_interest.appetite).to eq("actively_looking")

              expect(school.placements.where(subject_id: primary_with_english.id).count).to eq(1)
              expect(school.placements.where(subject_id: english.id).count).to eq(1)

              expect(school.partner_providers).to contain_exactly(
                test_provider_1,
                test_provider_3,
              )

              school_contact = school.school_contact
              expect(school_contact.first_name).to eq("Joe")
              expect(school_contact.last_name).to eq("Bloggs")
              expect(school_contact.email_address).to eq("joe_bloggs@example.com")
            end
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
            "school_contact" => {
              "first_name" => "Joe",
              "last_name" => "Bloggs",
              "email_address" => "joe_bloggs@example.com",
            },
          }
        end

        context "when school has no hosting interest for the next academic year" do
          context "when school has no school contact assigned" do
            let(:school) { create(:placements_school, with_school_contact: false) }

            it "creates hosting interest for the next academic year, assigns the appetite,
              reasons not hosting and creates a school contact" do
              expect { update_school_placements }.to change(Placements::HostingInterest, :count).by(1)
                .and change(Placements::SchoolContact, :count).by(1)
              school.reload

              hosting_interest = school.hosting_interests.last
              expect(hosting_interest.appetite).to eq("not_open")
              expect(hosting_interest.reasons_not_hosting).to contain_exactly(
                "Not enough trained mentors",
                "Number of pupils with SEND needs",
                "Working to improve our OFSTED rating",
              )

              school_contact = school.school_contact
              expect(school_contact.first_name).to eq("Joe")
              expect(school_contact.last_name).to eq("Bloggs")
              expect(school_contact.email_address).to eq("joe_bloggs@example.com")
            end
          end

          context "when the school already has a school contact" do
            it "creates hosting interest for the next academic year, assigns the appetite,
              reasons not hosting and updates the school contact" do
              expect { update_school_placements }.not_to change(Placements::SchoolContact, :count)
              school.reload

              hosting_interest = school.hosting_interests.last
              expect(hosting_interest.appetite).to eq("not_open")
              expect(hosting_interest.reasons_not_hosting).to contain_exactly(
                "Not enough trained mentors",
                "Number of pupils with SEND needs",
                "Working to improve our OFSTED rating",
              )

              school_contact = school.school_contact
              expect(school_contact.first_name).to eq("Joe")
              expect(school_contact.last_name).to eq("Bloggs")
              expect(school_contact.email_address).to eq("joe_bloggs@example.com")
            end
          end
        end

        context "when the school already has a hosting interest for the next academic year" do
          let(:hosting_interest) { create(:hosting_interest, :for_next_year, school:) }

          before { hosting_interest }

          it "updates the hosting interest for the next academic year, assigns the appetite,
            reasons not hosting and updates the school contact" do
            expect { update_school_placements }.not_to change(Placements::HostingInterest, :count)
            school.reload
            hosting_interest.reload

            expect(hosting_interest.appetite).to eq("not_open")
            expect(hosting_interest.reasons_not_hosting).to contain_exactly(
              "Not enough trained mentors",
              "Number of pupils with SEND needs",
              "Working to improve our OFSTED rating",
            )

            school_contact = school.school_contact
            expect(school_contact.first_name).to eq("Joe")
            expect(school_contact.last_name).to eq("Bloggs")
            expect(school_contact.email_address).to eq("joe_bloggs@example.com")
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
            "school_contact" => {
              "first_name" => "Joe",
              "last_name" => "Bloggs",
              "email_address" => "joe_bloggs@example.com",
            },
          }
        end

        it "returns an error" do
          expect { update_school_placements }.to raise_error "Invalid wizard state"
        end
      end
    end
  end

  describe "#upcoming_academic_year" do
    subject(:upcoming_academic_year) { wizard.upcoming_academic_year }

    let(:next_academic_year) { Placements::AcademicYear.current.next }

    before { next_academic_year }

    it "returns the next academic year" do
      expect(upcoming_academic_year).to eq(next_academic_year)
    end
  end

  describe "#setup_state" do
    subject(:setup_state) { wizard.setup_state }

    context "when the school has no school contact or hosting interest for the next year" do
      let(:school) { create(:placements_school, with_school_contact: false) }

      it "returns nil" do
        expect(setup_state).to be_nil
      end
    end

    context "when the school has a school contact" do
      let(:school_contact) { school.school_contact }

      it "returns a hash containing the school contacts attributes" do
        setup_state
        expect(state).to eq(
          {
            "school_contact" => {
              "first_name" => school_contact.first_name,
              "last_name" => school_contact.last_name,
              "email_address" => school_contact.email_address,
            },
          },
        )
      end
    end

    context "when the school has a hosting interest for the next academic year" do
      let(:school) { create(:placements_school, with_school_contact: false) }
      let(:hosting_interest) do
        create(:hosting_interest,
               school:,
               academic_year: Placements::AcademicYear.current.next,
               appetite: "actively_looking",
               reasons_not_hosting: [
                 "Not enough trained mentors",
                 "Number of pupils with SEND needs",
               ])
      end

      before { hosting_interest }

      it "returns a hash containing the attributes for the schools hosting interest" do
        setup_state
        expect(state).to eq(
          {
            "appetite" => { "appetite" => "actively_looking" },
            "reason_not_hosting" => { "reasons_not_hosting" => [
              "Not enough trained mentors", "Number of pupils with SEND needs"
            ] },
          },
        )
      end
    end
  end

  describe "#selected_primary_subjects" do
    subject(:selected_primary_subjects) { wizard.selected_primary_subjects }

    context "when a primary subject has not been selected" do
      it "returns an empty array" do
        expect(selected_primary_subjects).to eq([])
      end
    end

    context "when a primary subject has been selected" do
      let!(:primary_subject) { create(:subject, :primary, name: "Primary") }
      let!(:primary_with_english) { create(:subject, :primary, name: "Primary with english") }
      let(:primary_with_science) { create(:subject, :primary, name: "Primary with science") }
      let(:secondary_subject) { create(:subject, :secondary, name: "Science") }
      let(:state) do
        {
          "appetite" => { "appetite" => "actively_looking" },
          "phase" => { "phases" => %w[Primary] },
          "subjects_known" => { "subjects_known" => "Yes" },
          "primary_subject_selection" => { "subject_ids" => [primary_subject.id, primary_with_english.id] },
        }
      end

      before do
        primary_with_science
        secondary_subject
      end

      it "returns a list of selected primary subjects" do
        expect(selected_primary_subjects).to contain_exactly(primary_subject, primary_with_english)
      end
    end
  end

  describe "#selected_secondary_subjects" do
    subject(:selected_secondary_subjects) { wizard.selected_secondary_subjects }

    context "when a secondary subject has not been selected" do
      it "returns an empty array" do
        expect(selected_secondary_subjects).to eq([])
      end
    end

    context "when a secondary subject has been selected" do
      let(:primary_subject) { create(:subject, :primary, name: "Primary") }
      let!(:english) { create(:subject, :secondary, name: "English") }
      let!(:mathematics) { create(:subject, :secondary, name: "Mathematics") }
      let(:science) { create(:subject, :secondary, name: "Science") }
      let(:state) do
        {
          "appetite" => { "appetite" => "actively_looking" },
          "phase" => { "phases" => %w[Secondary] },
          "subjects_known" => { "subjects_known" => "Yes" },
          "secondary_subject_selection" => { "subject_ids" => [english.id, mathematics.id] },
        }
      end

      before do
        science
        primary_subject
      end

      it "returns a list of selected secondary subjects" do
        expect(selected_secondary_subjects).to contain_exactly(english, mathematics)
      end
    end
  end

  describe "#selected_providers" do
    subject(:selected_providers) { wizard.selected_providers }

    let(:test_provider_1) { create(:provider, name: "Test Provider 123") }
    let(:test_provider_2) { create(:provider, name: "Test Provider 456") }
    let(:test_provider_3) { create(:provider, name: "Test Provider 789") }

    context "when no provider_ids have been selected in the provider step" do
      it "returns an empty list" do
        expect(selected_providers).to eq([])
      end
    end

    context "when 'select_all' has been selected in the provider step" do
      let(:state) do
        {
          "appetite" => { "appetite" => "actively_looking" },
          "provider" => { "provider_ids" => %w[select_all] },
        }
      end

      before do
        test_provider_1
        test_provider_2
        test_provider_3
      end

      it "returns all test providers" do
        expect(selected_providers).to contain_exactly(
          test_provider_1,
          test_provider_2,
          test_provider_3,
        )
      end
    end

    context "when specific provider ids have been selected in the provider step" do
      let(:state) do
        {
          "appetite" => { "appetite" => "actively_looking" },
          "provider" => { "provider_ids" => [test_provider_1.id, test_provider_3.id] },
        }
      end

      before do
        test_provider_1
        test_provider_2
        test_provider_3
      end

      it "returns all test providers" do
        expect(selected_providers).to contain_exactly(
          test_provider_1,
          test_provider_3,
        )
      end
    end
  end
end
