require "rails_helper"

RSpec.describe Claims::RevertClaimsToSubmitted do
  describe "#call" do
    before do
      create(:claim)
      create(:claim, :draft)
      create(:claim, :submitted)
      create(:claim, :submitted, status: :paid)
      create(:claim, :payment_in_progress)
      create(:claim, :payment_information_requested)
      create(:claim, :payment_information_sent)
      create(:claim, :submitted, status: :payment_not_approved, unpaid_reason: "Unpaid")
      create(:claim, :submitted, status: :sampling_in_progress, sampling_reason: "Sampled")
      create(:claim, :submitted, status: :sampling_provider_not_approved, sampling_reason: "Sampled")
      create(:claim, :submitted, status: :sampling_not_approved, sampling_reason: "Sampled")
      create(:claim, :submitted, status: :clawback_requested)
      create(:claim, :submitted, status: :clawback_in_progress)
      create(:claim, :submitted, status: :clawback_complete)
      create(:claim, :audit_requested, status: :clawback_requires_approval)
      create(:claim, :audit_requested, status: :clawback_rejected)

      create_list(:claim_activity, 5, :sampling_uploaded)
    end

    context "when the environment is not Production" do
      it "reverts the status of all non-draft claims to submitted" do
        expect { described_class.call }.to change(Claims::Claim.submitted, :count).from(1).to(14)
          .and not_change(Claims::Claim.draft, :count)
          .and not_change(Claims::Claim.internal_draft, :count)
          .and change(Claims::ClaimActivity, :count).from(5).to(0)
      end

      it "updates all sampling_reasons, unpaid_reasons and payment_in_progress_at attributes to nil" do
        described_class.call
        expect(Claims::Claim.distinct.pluck(:sampling_reason)).to contain_exactly(nil)
        expect(Claims::Claim.distinct.pluck(:unpaid_reason)).to contain_exactly(nil)
        expect(Claims::Claim.distinct.pluck(:payment_in_progress_at)).to contain_exactly(nil)
      end

      context "when the claim has mentor trainings" do
        before do
          create(:mentor_training, :submitted)
          create(:mentor_training, :not_assured)
          create(:mentor_training, :rejected)
          create(
            :mentor_training,
            :rejected,
            hours_clawed_back: 20,
            reason_clawed_back: "Reason",
          )
          create(
            :mentor_training,
            :rejected,
            hours_clawed_back: 20,
            reason_clawed_back: "Reason",
            reason_clawback_rejected: "Clawback rejected",
          )
        end

        it "updates the hours_clawed_back, reason_clawed_back, reason_not_assured,
          not_assured, reason_rejected, rejected attributes to nil (or false if boolean)" do
          described_class.call
          expect(Claims::MentorTraining.distinct.pluck(:hours_clawed_back)).to contain_exactly(nil)
          expect(Claims::MentorTraining.distinct.pluck(:reason_clawed_back)).to contain_exactly(nil)
          expect(Claims::MentorTraining.distinct.pluck(:reason_not_assured)).to contain_exactly(nil)
          expect(Claims::MentorTraining.distinct.pluck(:not_assured)).to contain_exactly(false)
          expect(Claims::MentorTraining.distinct.pluck(:reason_rejected)).to contain_exactly(nil)
          expect(Claims::MentorTraining.distinct.pluck(:rejected)).to contain_exactly(false)
          expect(Claims::MentorTraining.distinct.pluck(:reason_clawed_back)).to contain_exactly(nil)
          expect(Claims::MentorTraining.distinct.pluck(:reason_clawback_rejected)).to contain_exactly(nil)
        end
      end
    end

    context "when the environment is Production" do
      it "does nothing in Production" do
        allow(HostingEnvironment).to receive(:env).and_return(ActiveSupport::EnvironmentInquirer.new("production"))

        expect { described_class.call }.to not_change(Claims::Claim.submitted, :count)
          .and not_change(Claims::ClaimActivity, :count)
      end
    end
  end
end
