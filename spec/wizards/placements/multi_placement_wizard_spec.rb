require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard do
  subject(:wizard) { described_class.new(state:, params:, school:, current_step:) }

  let(:school) { create(:placements_school) }
  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:current_step) { nil }

  describe "#steps" do
    subject { wizard.steps.keys }

    it { is_expected.to eq %i[appetite school_contact] }

    context "when an appetite is set to 'not_open' during the appetite step" do
      let(:state) do
        {
          "appetite" => { "appetite" => "not_open" },
        }
      end

      it { is_expected.to eq %i[appetite reason_not_hosting help school_contact] }
    end
  end

  describe "#update_school_placements" do
    subject(:update_school_placements) { wizard.update_school_placements }

    before { school }

    context "when the attributes passed are valid" do
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
end
