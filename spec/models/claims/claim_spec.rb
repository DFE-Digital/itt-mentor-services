# == Schema Information
#
# Table name: claims
#
#  id                   :uuid             not null, primary key
#  created_by_type      :string
#  reference            :string
#  reviewed_by_user     :boolean          default(FALSE)
#  status               :enum
#  submitted_at         :datetime
#  submitted_by_type    :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  created_by_id        :uuid
#  next_revision_id     :uuid
#  previous_revision_id :uuid
#  provider_id          :uuid
#  school_id            :uuid             not null
#  submitted_by_id      :uuid
#
# Indexes
#
#  index_claims_on_created_by            (created_by_type,created_by_id)
#  index_claims_on_next_revision_id      (next_revision_id)
#  index_claims_on_previous_revision_id  (previous_revision_id)
#  index_claims_on_provider_id           (provider_id)
#  index_claims_on_school_id             (school_id)
#  index_claims_on_submitted_by          (submitted_by_type,submitted_by_id)
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
    it { is_expected.to belong_to(:previous_revision).class_name("Claims::Claim").optional }
    it { is_expected.to belong_to(:next_revision).class_name("Claims::Claim").optional }
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
        .with_values(internal_draft: "internal_draft", draft: "draft", submitted: "submitted")
        .backed_by_column_of_type(:enum)
    end
  end

  describe "scopes" do
    describe "#visible" do
      it "returns the claims that dont have status internal_draft" do
        create(:claim)
        claim1 = create(:claim, :draft)
        claim2 = create(:claim, :submitted)
        create(:claim, :internal_draft)

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

  describe "#deep_dup" do
    it "builds a deep duplication of the claim, with associations" do
      claim = create(:claim, :draft)
      attributes = claim.attributes.except(
        "id",
        "created_at",
        "updated_at",
        "status",
        "previous_revision_id",
        "next_revision_id",
      ).keys
      dup_record = claim.deep_dup

      expect(dup_record.mentor_trainings).to eq(claim.mentor_trainings)
      expect(dup_record.previous_revision_id).to eq(claim.id)
      expect(dup_record.status).to eq("internal_draft")

      attributes.each do |attribute|
        expect(dup_record.public_send(attribute)).to eq(claim.public_send(attribute))
      end
    end
  end

  describe "#create_revision!" do
    it "creates a revision of the claim, with associations" do
      anne = create(:claims_user, :anne)
      claim = create(:claim, :draft, submitted_by: anne, created_by: anne)
      attributes = claim.attributes.except(
        "id",
        "created_at",
        "updated_at",
        "status",
        "previous_revision_id",
        "next_revision_id",
      ).keys
      revision = claim.create_revision!

      expect(revision.mentor_trainings).to eq(claim.mentor_trainings)
      expect(revision.previous_revision_id).to eq(claim.id)
      expect(revision.status).to eq("internal_draft")
      expect(claim.next_revision_id).to eq(revision.id)

      attributes.each do |attribute|
        expect(revision.public_send(attribute)).to eq(claim.public_send(attribute))
      end
    end
  end

  describe "#get_valid_revision" do
    it "gets the last valid revision" do
      valid_revision = create(:claim, :draft)
      create(:mentor_training, claim: valid_revision, hours_completed: 20)
      invalid_revision = create(
        :claim,
        :draft,
        previous_revision: valid_revision,
      )
      create(:mentor_training, claim: invalid_revision, hours_completed: nil)
      claim = create(:claim, :draft, previous_revision: invalid_revision)
      revision = claim.get_valid_revision

      expect(revision).to eq(valid_revision)
    end
  end

  describe "#has_revision?" do
    it "returns true if previous_revision_id is present" do
      previous_revision = create(:claim)
      claim = build(:claim, previous_revision:)

      expect(claim.has_revision?).to eq(true)
    end

    it "returns false if previous_revision_id is not present" do
      claim = build(:claim, previous_revision: nil)

      expect(claim.has_revision?).to eq(false)
    end

    it "returns true if next_revision_id is present" do
      next_revision = create(:claim)
      claim = build(:claim, next_revision:)

      expect(claim.has_revision?).to eq(true)
    end

    it "returns true if next_revision_id is not present" do
      claim = build(:claim, next_revision: nil)

      expect(claim.has_revision?).to eq(false)
    end
  end

  describe "#was_draft?" do
    it "returns true if any previous revision was draft" do
      draft_revision = create(:claim, :draft)
      revision = create(
        :claim,
        :internal_draft,
        previous_revision: draft_revision,
      )
      claim = create(:claim, :submitted, previous_revision: revision)

      expect(claim.was_draft?).to eq(true)
    end

    it "returns false if no previous revision was draft" do
      second_revision = create(:claim, :internal_draft)
      revision = create(
        :claim,
        :internal_draft,
        previous_revision: second_revision,
      )
      claim = create(:claim, :submitted, previous_revision: revision)

      expect(claim.was_draft?).to eq(false)
    end
  end
end
