# == Schema Information
#
# Table name: claims
#
#  id                :uuid             not null, primary key
#  created_by_type   :string
#  reference         :string
#  status            :enum
#  submitted_at      :datetime
#  submitted_by_type :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  created_by_id     :uuid
#  provider_id       :uuid
#  school_id         :uuid             not null
#  submitted_by_id   :uuid
#
# Indexes
#
#  index_claims_on_created_by    (created_by_type,created_by_id)
#  index_claims_on_provider_id   (provider_id)
#  index_claims_on_reference     (reference) UNIQUE
#  index_claims_on_school_id     (school_id)
#  index_claims_on_submitted_by  (submitted_by_type,submitted_by_id)
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
    it { is_expected.to belong_to(:submitted_by).optional }
    it { is_expected.to have_many(:mentor_trainings).dependent(:destroy) }
    it { is_expected.to have_many(:mentors).through(:mentor_trainings) }
  end

  context "with validations" do
    subject { build(:claim) }

    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_uniqueness_of(:reference).case_insensitive.allow_nil }
  end

  context "with delegations" do
    it { is_expected.to delegate_method(:name).to(:provider).with_prefix }
    it { is_expected.to delegate_method(:users).to(:school).with_prefix }
    it { is_expected.to delegate_method(:full_name).to(:submitted_by).with_prefix.allow_nil }
  end

  describe "auditing" do
    it { is_expected.to be_audited }
    it { is_expected.to have_associated_audits }
  end

  describe "enums" do
    subject(:claim) { build(:claim) }

    it "defines the expected values" do
      expect(claim).to define_enum_for(:status)
        .with_values(internal: "internal", draft: "draft", submitted: "submitted")
        .backed_by_column_of_type(:enum)
    end
  end

  describe "scopes" do
    describe "#visible" do
      it "returns the claims that dont have status internal" do
        create(:claim)
        claim1 = create(:claim, :draft)
        claim2 = create(:claim, :submitted)
        create(:claim, :internal)

        expect(described_class.visible).to eq(
          [claim1, claim2],
        )
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
  end

  describe "#submitted_on" do
    it "returns the submitted_at in date format" do
      claim = build(:claim, submitted_at: Time.zone.local(2024, 2, 4, 10, 10))

      expect(claim.submitted_on).to eq(Date.new(2024, 2, 4))
    end

    context "when submitted_at is nil" do
      it "returns nil" do
        claim = build(:claim)

        expect(claim.submitted_on).to eq(nil)
      end
    end
  end

  describe "#ready_to_be_checked?" do
    it "returns true if the claim's mentors all have their hours recorded" do
      claim = create(:claim)
      create(:mentor_training, hours_completed: 20, claim:)

      expect(claim.ready_to_be_checked?).to eq(true)
    end

    it "returns false if the claim does have mentors" do
      claim = build(:claim)

      expect(claim.ready_to_be_checked?).to eq(false)
    end

    it "returns false if the claim does have mentor training hours" do
      claim = create(:claim)
      create(:mentor_training, hours_completed: nil, claim:)

      expect(claim.ready_to_be_checked?).to eq(false)
    end
  end
end
