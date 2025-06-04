require "rails_helper"

RSpec.describe SupportHelper do
  describe ".deactivate_school" do
    subject(:deactivate_school) { described_class.deactivate_school(school:, claims_service:, placements_service:) }

    let(:claims_mentor) { build(:mentor) }
    let(:placements_mentor) { build(:mentor) }
    let(:claims_user) { build(:claims_user) }
    let(:placements_user) { create(:placements_user) }
    let(:school) do
      create(:school, claims_service: is_claims_school, placements_service: is_placements_school)
    end
    let(:claim_window) { Claims::ClaimWindow.current || create(:claim_window, :current) }
    let(:claims_school) { school.becomes(Claims::School) }
    let(:placements_school) { school.becomes(Placements::School) }

    context "when deactivating a school from the claims service" do
      let(:claims_service) { true }
      let(:is_claims_school) { true }
      let(:placements_service) { false }
      let(:is_placements_school) { false }

      before do
        create(:claim, :draft, school: claims_school)
        create(:claim, :submitted, school: claims_school)
        create(:user_membership, user: claims_user, organisation: school)
        create(:mentor_membership, :claims, mentor: claims_mentor, school: claims_school)
        create(:eligibility, school: claims_school, claim_window:)
      end

      context "when the school has claims only in draft or submitted statuses" do
        it "deactivates the school only from the claims service" do
          expect { deactivate_school }.to change { Claims::Claim.where(school: claims_school).count }.from(2).to(0)
            .and change { UserMembership.where(organisation: claims_school).count }.from(1).to(0)
            .and change { Claims::MentorMembership.where(school: claims_school).count }.from(1).to(0)
            .and change { Claims::Eligibility.where(school: claims_school).count }.from(1).to(0)
            .and change(school, :claims_service).from(true).to(false)
        end

        context "when the school is also onboarded to the placements service" do
          let(:is_placements_school) { true }

          it "does not remove the school from the placements service" do
            expect { deactivate_school }.not_to change(school, :placements_service)
          end
        end
      end

      context "when the school has claims not in the draft or submitted status" do
        before do
          create(:claim, :paid, school: claims_school)
        end

        it "raises an error" do
          expect { deactivate_school }.to raise_error(
            "School has claims not in draft or submitted. School can not be offboarded.",
          )
        end
      end
    end

    context "when deactivating a school from the placements service" do
      let(:claims_service) { false }
      let(:is_claims_school) { false }
      let(:placements_service) { true }
      let(:is_placements_school) { true }

      before do
        _unassigned_placement = create(:placement, school: placements_school)
        create(:user_membership, user: placements_user, organisation: school)
        create(:mentor_membership, :placements, mentor: placements_mentor, school: placements_school)
        create(:placements_partnership, school: placements_school)
        create(:hosting_interest, school: placements_school)
      end

      context "when the school has no placements assigned to a provider" do
        it "deactivates the school only from the placements service" do
          expect { deactivate_school }.to change { Placement.where(school: placements_school).count }.from(1).to(0)
            .and change { UserMembership.where(organisation: placements_school).count }.from(1).to(0)
            .and change { Placements::MentorMembership.where(school: placements_school).count }.from(1).to(0)
            .and change { Placements::Partnership.where(school: placements_school).count }.from(1).to(0)
            .and change { Placements::HostingInterest.where(school: placements_school).count }.from(1).to(0)
            .and change(school, :placements_service).from(true).to(false)
        end

        context "when the school is also onboarded on the claims service" do
          it "does not remove the school from the claims service" do
            expect { deactivate_school }.not_to change(school, :claims_service)
          end
        end
      end

      context "when the school has a placement assigned to a provder" do
        before do
          _assigned_placement = create(
            :placement,
            school: placements_school,
            provider: build(:placements_provider),
          )
        end

        it "raises an error" do
          expect { deactivate_school }.to raise_error(
            "School has placements assigned to providers. School can not be offboarded.",
          )
        end
      end
    end

    context "when deactivating the school from both the claims and placements service" do
      let(:claims_service) { true }
      let(:is_claims_school) { true }
      let(:placements_service) { true }
      let(:is_placements_school) { true }

      before do
        create(:claim, :draft, school: claims_school)
        create(:claim, :submitted, school: claims_school)
        create(:user_membership, user: claims_user, organisation: school)
        create(:mentor_membership, :claims, mentor: claims_mentor, school: claims_school)
        create(:eligibility, school: claims_school, claim_window:)
        _unassigned_placement = create(:placement, school: placements_school)
        create(:user_membership, user: placements_user, organisation: school)
        create(:mentor_membership, :placements, mentor: placements_mentor, school: placements_school)
        create(:placements_partnership, school: placements_school)
        create(:hosting_interest, school: placements_school)
      end

      it "deactivates the school from both the claims and placements service" do
        expect { deactivate_school }.to change { Placement.where(school: placements_school).count }.from(1).to(0)
          .and change { UserMembership.where(organisation: school).count }.from(2).to(0)
          .and change { Placements::MentorMembership.where(school: placements_school).count }.from(1).to(0)
          .and change { Placements::Partnership.where(school: placements_school).count }.from(1).to(0)
          .and change { Placements::HostingInterest.where(school: placements_school).count }.from(1).to(0)
          .and change { Placement.where(school: placements_school).count }.from(1).to(0)
          .and change { Placements::MentorMembership.where(school: placements_school).count }.from(1).to(0)
          .and change { Placements::Partnership.where(school: placements_school).count }.from(1).to(0)
          .and change { Placements::HostingInterest.where(school: placements_school).count }.from(1).to(0)
          .and change(school, :placements_service).from(true).to(false)
          .and change(school, :placements_service).from(true).to(false)
      end
    end
  end
end
