# == Schema Information
#
# Table name: claims
#
#  id                     :uuid             not null, primary key
#  created_by_type        :string
#  payment_in_progress_at :datetime
#  reference              :string
#  reviewed               :boolean          default(FALSE)
#  sampling_reason        :text
#  status                 :enum
#  submitted_at           :datetime
#  submitted_by_type      :string
#  unpaid_reason          :text
#  zendesk_url            :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  claim_window_id        :uuid
#  created_by_id          :uuid
#  provider_id            :uuid
#  school_id              :uuid             not null
#  submitted_by_id        :uuid
#  support_user_id        :uuid
#
# Indexes
#
#  index_claims_on_claim_window_id  (claim_window_id)
#  index_claims_on_created_by       (created_by_type,created_by_id)
#  index_claims_on_provider_id      (provider_id)
#  index_claims_on_reference        (reference)
#  index_claims_on_school_id        (school_id)
#  index_claims_on_submitted_by     (submitted_by_type,submitted_by_id)
#  index_claims_on_support_user_id  (support_user_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#
require "rails_helper"

RSpec.describe Claims::Claim, type: :model do
  context "with associations" do
    it { is_expected.to belong_to(:school).class_name("Claims::School") }
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:created_by) }
    it { is_expected.to belong_to(:claim_window) }
    it { is_expected.to belong_to(:support_user).class_name("Claims::SupportUser").optional }
    it { is_expected.to belong_to(:submitted_by).optional }
    it { is_expected.to have_many(:mentor_trainings).dependent(:destroy) }
    it { is_expected.to have_many(:mentors).through(:mentor_trainings) }
    it { is_expected.to have_many(:provider_sampling_claims).dependent(:destroy) }
    it { is_expected.to have_many(:provider_samplings).through(:provider_sampling_claims) }
    it { is_expected.to have_many(:clawback_claims).dependent(:destroy) }
  end

  context "with validations" do
    subject { create(:claim) }

    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_uniqueness_of(:reference).case_insensitive.allow_nil }
  end

  describe "#valid_mentor_training_hours?" do
    it "returns true when each mentor does not have more hours than maximum allocated per provider" do
      claim = create(:claim, :submitted)
      create(:mentor_training, claim:, hours_completed: 20)
      create(:mentor_training, claim:, hours_completed: 20)

      expect(claim.valid_mentor_training_hours?).to be(true)
    end

    it "returns false when a mentor has more hours than maximum allocated per provider" do
      provider = create(:claims_provider)
      claim = create(:claim, :submitted, provider:)
      mentor = create(:claims_mentor)
      create(:mentor_training, claim:, hours_completed: 20, mentor:, provider:)
      create(:mentor_training, claim:, hours_completed: 20, mentor:, provider:)

      expect(claim.valid_mentor_training_hours?).to be(false)
    end
  end

  context "with delegations" do
    it { is_expected.to delegate_method(:name).to(:provider).with_prefix }
    it { is_expected.to delegate_method(:users).to(:school).with_prefix }
    it { is_expected.to delegate_method(:urn).to(:school).with_prefix }
    it { is_expected.to delegate_method(:region_funding_available_per_hour).to(:school).with_prefix }
    it { is_expected.to delegate_method(:postcode).to(:school).with_prefix }
    it { is_expected.to delegate_method(:full_name).to(:submitted_by).with_prefix.allow_nil }
    it { is_expected.to delegate_method(:name).to(:academic_year).with_prefix.allow_nil }
  end

  describe "auditing" do
    it { is_expected.to be_audited }
    it { is_expected.to have_associated_audits }
  end

  describe "enums" do
    subject(:claim) { build(:claim) }

    it "defines the expected values" do
      expect(claim).to define_enum_for(:status)
        .with_values(
          internal_draft: "internal_draft",
          draft: "draft",
          submitted: "submitted",
          payment_in_progress: "payment_in_progress",
          payment_information_requested: "payment_information_requested",
          payment_information_sent: "payment_information_sent",
          paid: "paid",
          payment_not_approved: "payment_not_approved",
          sampling_in_progress: "sampling_in_progress",
          sampling_provider_not_approved: "sampling_provider_not_approved",
          sampling_not_approved: "sampling_not_approved",
          clawback_requested: "clawback_requested",
          clawback_in_progress: "clawback_in_progress",
          clawback_complete: "clawback_complete",
        )
        .backed_by_column_of_type(:enum)
    end
  end

  describe "scopes" do
    describe "#active" do
      it "returns the claims that dont have status internal_draft" do
        create(:claim)
        claim1 = create(:claim, :draft)
        claim2 = create(:claim, :submitted)
        create(:claim, :internal_draft)

        expect(described_class.active).to contain_exactly(claim1, claim2)
      end
    end

    describe "order_by_created_at" do
      it "returns the claims ordered by created at" do
        claim1 = create(:claim, :draft, created_at: Time.current)
        claim2 = create(:claim, :draft, created_at: 2.hours.ago)
        claim3 = create(:claim, :submitted, created_at: 1.hour.ago)

        expect(described_class.order_created_at_desc).to eq(
          [claim1, claim3, claim2],
        )
      end
    end

    describe "not_draft_status" do
      let!(:submitted_claim) { create(:claim, :submitted) }
      let(:draft_claim) { create(:claim, :draft) }
      let(:internal_draft_claim) { create(:claim) }

      before do
        draft_claim
        internal_draft_claim
      end

      it "returns all claims which are not in a draft or internal draft status" do
        expect(described_class.not_draft_status).to contain_exactly(submitted_claim)
      end
    end

    describe "#paid_for_current_academic_year" do
      let(:current_academic_year) do
        AcademicYear.for_date(Date.current) || create(:academic_year, :current)
      end
      let(:current_claim_window) do
        create(:claim_window,
               starts_on: current_academic_year.starts_on + 1.day,
               ends_on: current_academic_year.starts_on + 1.month,
               academic_year: current_academic_year)
      end
      let(:current_year_paid_claim) do
        create(:claim, :submitted, status: :paid, claim_window: current_claim_window)
      end
      let(:another_paid_claim) { create(:claim, :submitted, status: :paid) }
      let(:current_year_draft_claim) { create(:claim, :draft, claim_window: current_claim_window) }

      before do
        current_year_paid_claim
        another_paid_claim
        current_year_draft_claim
      end

      it "returns only paid claim, submitted during the current academic year" do
        expect(described_class.paid_for_current_academic_year).to contain_exactly(current_year_paid_claim)
      end
    end
  end

  describe "#submitted_on" do
    it "returns the submitted_at in date format" do
      claim = build(:claim, submitted_at: Time.zone.local(2024, 2, 4, 10, 10))

      expect(claim.submitted_on).to eq(Date.new(2024, 2, 4))
    end

    context "when submitted_at is nil" do
      it "returns nil" do
        claim = build(:claim)

        expect(claim.submitted_on).to be_nil
      end
    end
  end

  describe "#ready_to_be_checked?" do
    it "returns true if the claim's mentors all have their hours recorded" do
      claim = create(:claim)
      create(:mentor_training, hours_completed: 20, claim:)

      expect(claim.ready_to_be_checked?).to be(true)
    end

    it "returns false if the claim does have mentors" do
      claim = build(:claim)

      expect(claim.ready_to_be_checked?).to be(false)
    end

    it "returns false if the claim does have mentor training hours" do
      claim = create(:claim)
      create(:mentor_training, hours_completed: nil, claim:)

      expect(claim.ready_to_be_checked?).to be(false)
    end
  end

  describe "#total_clawback_amount" do
    let(:claim) { create(:claim) }

    before do
      allow(claim.school).to receive(:region_funding_available_per_hour).and_return(15)
    end

    context "when there are multiple not_assured mentor trainings" do
      it "returns the total clawback amount for the claim calculated from both mentors" do
        create(:mentor_training, claim:, hours_clawed_back: 10, not_assured: true, reason_not_assured: "reason")
        create(:mentor_training, claim:, hours_clawed_back: 20, not_assured: true, reason_not_assured: "reason")

        expect(claim.total_clawback_amount).to eq(450.0)
      end
    end

    context "when one mentor training is not_assured" do
      it "returns the total clawback amount for the claim from the not_assured mentor" do
        create(:mentor_training, claim:, hours_clawed_back: 10, not_assured: false)
        create(:mentor_training, claim:, hours_clawed_back: 20, not_assured: true, reason_not_assured: "reason")

        expect(claim.total_clawback_amount).to eq(300.0)
      end
    end

    context "when there are no not_assured mentor trainings" do
      it "returns 0" do
        create(:mentor_training, claim:, hours_clawed_back: 10, not_assured: false)
        create(:mentor_training, claim:, hours_clawed_back: 20, not_assured: false)

        expect(claim.total_clawback_amount).to eq(0)
      end
    end
  end

  describe "#in_draft?" do
    subject(:in_draft) { claim.in_draft? }

    context "when the claim has the status internal draft" do
      let(:claim) { create(:claim) }

      it "returns true" do
        expect(in_draft).to be(true)
      end
    end

    context "when the claim has the status draft" do
      let(:claim) { create(:claim, :draft) }

      it "returns true" do
        expect(in_draft).to be(true)
      end
    end

    context "when the claim has status submitted" do
      let(:claim) { create(:claim, :submitted) }

      it "returns false" do
        expect(in_draft).to be(false)
      end
    end

    context "when the claim has status payment in progress" do
      let(:claim) { create(:claim, :submitted, status: :payment_in_progress) }

      it "returns false" do
        expect(in_draft).to be(false)
      end
    end

    context "when the claim has status payment information requested" do
      let(:claim) { create(:claim, :submitted, status: :payment_information_requested) }

      it "returns false" do
        expect(in_draft).to be(false)
      end
    end

    context "when the claim has status payment information sent" do
      let(:claim) { create(:claim, :submitted, status: :payment_information_sent) }

      it "returns false" do
        expect(in_draft).to be(false)
      end
    end

    context "when the claim has status paid" do
      let(:claim) { create(:claim, :submitted, status: :paid) }

      it "returns false" do
        expect(in_draft).to be(false)
      end
    end

    context "when the claim has status payment not approved" do
      let(:claim) { create(:claim, :submitted, status: :payment_not_approved) }

      it "returns false" do
        expect(in_draft).to be(false)
      end
    end

    context "when the claim has status sampling in progress" do
      let(:claim) { create(:claim, :submitted, status: :sampling_in_progress) }

      it "returns false" do
        expect(in_draft).to be(false)
      end
    end

    context "when the claim has status sampling provider not approved" do
      let(:claim) { create(:claim, :submitted, status: :sampling_provider_not_approved) }

      it "returns false" do
        expect(in_draft).to be(false)
      end
    end

    context "when the claim has status sampling not approved" do
      let(:claim) { create(:claim, :submitted, status: :sampling_not_approved) }

      it "returns false" do
        expect(in_draft).to be(false)
      end
    end

    context "when the claim has status clawback requested" do
      let(:claim) { create(:claim, :submitted, status: :clawback_requested) }

      it "returns false" do
        expect(in_draft).to be(false)
      end
    end

    context "when the claim has status clawback in progress" do
      let(:claim) { create(:claim, :submitted, status: :clawback_in_progress) }

      it "returns false" do
        expect(in_draft).to be(false)
      end
    end

    context "when the claim has status clawback complete" do
      let(:claim) { create(:claim, :submitted, status: :clawback_complete) }

      it "returns false" do
        expect(in_draft).to be(false)
      end
    end
  end

  describe "#in_clawback?" do
    context "when the claim has status clawback_requested" do
      let(:claim) { create(:claim, status: :clawback_requested) }

      it "returns true" do
        expect(claim.in_clawback?).to be(true)
      end
    end

    context "when the claim has status clawback_in_progress" do
      let(:claim) { create(:claim, status: :clawback_in_progress) }

      it "returns true" do
        expect(claim.in_clawback?).to be(true)
      end
    end

    context "when the claim has status clawback_complete" do
      let(:claim) { create(:claim, status: :clawback_complete) }

      it "returns true" do
        expect(claim.in_clawback?).to be(true)
      end
    end

    context "when the claim has any other status" do
      let(:claim) { create(:claim, status: :submitted) }

      it "returns false" do
        expect(claim.in_clawback?).to be(false)
      end
    end
  end

  describe "#amount_after_clawback" do
    let(:claim) { create(:claim) }

    before do
      allow(claim).to receive_messages(amount: 1000, total_clawback_amount: 200)
    end

    it "returns the correct amount after clawback" do
      expect(claim.amount_after_clawback).to eq(800)
    end

    context "when the total clawback amount is 0" do
      before do
        allow(claim).to receive(:total_clawback_amount).and_return(0)
      end

      it "returns the original amount" do
        expect(claim.amount_after_clawback).to eq(1000)
      end
    end
  end

  describe "#total_hours_completed" do
    let(:claim) { create(:claim) }

    it "returns the total hours completed for the claim" do
      create(:mentor_training, claim:, hours_completed: 10)
      create(:mentor_training, claim:, hours_completed: 20)

      expect(claim.total_hours_completed).to eq(30)
    end
  end

  describe "#payment_actionable?" do
    subject(:payment_actionable) { claim.payment_actionable? }

    context "when the claim has the status internal draft" do
      let(:claim) { create(:claim) }

      it "returns false" do
        expect(payment_actionable).to be(false)
      end
    end

    context "when the claim has the status draft" do
      let(:claim) { create(:claim, :draft) }

      it "returns false" do
        expect(payment_actionable).to be(false)
      end
    end

    context "when the claim has status submitted" do
      let(:claim) { create(:claim, :submitted) }

      it "returns false" do
        expect(payment_actionable).to be(false)
      end
    end

    context "when the claim has status payment in progress" do
      let(:claim) { create(:claim, :payment_in_progress) }

      it "returns false" do
        expect(payment_actionable).to be(false)
      end
    end

    context "when the claim has status payment information requested" do
      let(:claim) { create(:claim, status: :payment_information_requested) }

      it "returns true" do
        expect(payment_actionable).to be(true)
      end
    end

    context "when the claim has status payment information sent" do
      let(:claim) { create(:claim, :payment_information_sent) }

      it "returns true" do
        expect(payment_actionable).to be(true)
      end
    end

    context "when the claim has status paid" do
      let(:claim) { create(:claim, :submitted, status: :paid) }

      it "returns false" do
        expect(payment_actionable).to be(false)
      end
    end

    context "when the claim has status payment not approved" do
      let(:claim) { create(:claim, :submitted, status: :payment_not_approved) }

      it "returns false" do
        expect(payment_actionable).to be(false)
      end
    end

    context "when the claim has status sampling in progress" do
      let(:claim) { create(:claim, :audit_requested) }

      it "returns false" do
        expect(payment_actionable).to be(false)
      end
    end

    context "when the claim has status sampling provider not approved" do
      let(:claim) { create(:claim, :audit_requested, status: :sampling_provider_not_approved) }

      it "returns false" do
        expect(payment_actionable).to be(false)
      end
    end

    context "when the claim has status sampling not approved" do
      let(:claim) { create(:claim, :audit_requested, status: :sampling_not_approved) }

      it "returns false" do
        expect(payment_actionable).to be(false)
      end
    end

    context "when the claim has status clawback requested" do
      let(:claim) { create(:claim, :audit_requested, status: :clawback_requested) }

      it "returns false" do
        expect(payment_actionable).to be(false)
      end
    end

    context "when the claim has status clawback in progress" do
      let(:claim) { create(:claim, :audit_requested, status: :clawback_in_progress) }

      it "returns false" do
        expect(payment_actionable).to be(false)
      end
    end

    context "when the claim has status clawback complete" do
      let(:claim) { create(:claim, :audit_requested, status: :clawback_complete) }

      it "returns false" do
        expect(payment_actionable).to be(false)
      end
    end
  end
end
