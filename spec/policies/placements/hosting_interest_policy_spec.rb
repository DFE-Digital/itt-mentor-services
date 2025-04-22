require "rails_helper"

describe Placements::HostingInterestPolicy do
  subject(:hosting_interest_policy) { described_class }

  let(:current_user) { create(:placements_user, schools: [school]) }
  let(:school) { create(:placements_school) }
  let(:hosting_interest) do
    create(
      :hosting_interest,
      school:,
      academic_year:,
      appetite:,
    )
  end
  let(:appetite) { "actively_looking" }

  permissions :edit? do
    context "when the hosting interest is not for the next academic year" do
      let(:academic_year) { Placements::AcademicYear.current }

      it "denies access" do
        expect(hosting_interest_policy).not_to permit(current_user, hosting_interest)
      end
    end

    context "when the hosting interest is for the next academic year" do
      let(:academic_year) { Placements::AcademicYear.current.next }

      context "when the appetite is 'not_open'" do
        let(:appetite) { "not_open" }

        it "grants access" do
          expect(hosting_interest_policy).to permit(current_user, hosting_interest)
        end
      end

      context "when the appetite is 'interested'" do
        let(:appetite) { "interested" }

        it "grants access" do
          expect(hosting_interest_policy).to permit(current_user, hosting_interest)
        end
      end

      context "when the appetite is 'actively_looking'" do
        context "when the school has no placements assigned to providers" do
          before do
            create(:placement, school:, academic_year:)
          end

          it "grants access" do
            expect(hosting_interest_policy).to permit(current_user, hosting_interest)
          end
        end

        context "when the school has placements assigned to providers" do
          before do
            create(
              :placement,
              school:,
              academic_year:,
              provider: create(:placements_provider),
            )
          end

          it "denies access" do
            expect(hosting_interest_policy).not_to permit(current_user, hosting_interest)
          end
        end
      end
    end
  end
end
