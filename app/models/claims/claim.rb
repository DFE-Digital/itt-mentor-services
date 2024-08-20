# == Schema Information
#
# Table name: claims
#
#  id                   :uuid             not null, primary key
#  created_by_type      :string
#  reference            :string
#  reviewed             :boolean          default(FALSE)
#  status               :enum
#  submitted_at         :datetime
#  submitted_by_type    :string
#  unpaid_reason        :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  claim_window_id      :uuid
#  created_by_id        :uuid
#  previous_revision_id :uuid
#  provider_id          :uuid
#  school_id            :uuid             not null
#  submitted_by_id      :uuid
#
# Indexes
#
#  index_claims_on_claim_window_id       (claim_window_id)
#  index_claims_on_created_by            (created_by_type,created_by_id)
#  index_claims_on_previous_revision_id  (previous_revision_id)
#  index_claims_on_provider_id           (provider_id)
#  index_claims_on_reference             (reference)
#  index_claims_on_school_id             (school_id)
#  index_claims_on_submitted_by          (submitted_by_type,submitted_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#
class Claims::Claim < ApplicationRecord
  MAXIMUM_CLAIMABLE_HOURS = 20
  audited
  has_associated_audits

  belongs_to :school
  belongs_to :provider
  belongs_to :claim_window
  belongs_to :created_by, polymorphic: true
  belongs_to :submitted_by, polymorphic: true, optional: true
  belongs_to :previous_revision, class_name: "Claims::Claim", optional: true

  has_one :academic_year, through: :claim_window

  has_many :mentor_trainings, dependent: :destroy
  has_many :mentors, through: :mentor_trainings

  validates :status, presence: true
  validates(
    :reference,
    uniqueness: { case_sensitive: false },
    allow_nil: true,
    unless: :has_revision?,
  )

  ACTIVE_STATUSES = %i[draft submitted].freeze
  DRAFT_STATUSES = %i[internal_draft draft].freeze

  scope :active, -> { where(status: ACTIVE_STATUSES) }
  scope :order_created_at_desc, -> { order(created_at: :desc) }
  scope :not_draft_status, -> { where.not(status: DRAFT_STATUSES) }

  enum :status,
       {
         internal_draft: "internal_draft",
         draft: "draft",
         submitted: "submitted",
         payment_in_progress: "payment_in_progress",
         paid: "paid",
         payment_information_requested: "payment_information_requested",
         payment_information_sent: "payment_information_sent",
         payment_not_approved: "payment_not_approved",
       },
       validate: true

  delegate :name, to: :provider, prefix: true, allow_nil: true
  delegate :users, to: :school, prefix: true
  delegate :full_name, to: :submitted_by, prefix: true, allow_nil: true
  delegate :name, to: :academic_year, prefix: true, allow_nil: true

  def valid_mentor_training_hours?
    mentor_trainings_without_current_claim = Claims::MentorTraining.joins(:claim)
      .merge(Claims::Claim.active).where(
        mentor_id: mentor_trainings.select(:mentor_id),
        provider_id:,
      ).where.not(claim_id: [id, previous_revision_id])
    grouped_trainings = [*mentor_trainings, *mentor_trainings_without_current_claim].group_by { [_1.mentor_id, _1.provider_id] }

    grouped_trainings.transform_values { _1.sum(&:hours_completed) }.values.all? { _1 <= MAXIMUM_CLAIMABLE_HOURS }
  end

  def submitted_on
    submitted_at&.to_date
  end

  def amount
    Claims::Claim::CalculateAmount.call(claim: self)
  end

  def active?
    ACTIVE_STATUSES.include?(status.to_sym)
  end

  def ready_to_be_checked?
    mentors.present? && mentor_trainings.without_hours.blank?
  end

  def get_valid_revision
    Claims::Claim::RemoveEmptyMentorTrainingHours.call(claim: self)

    mentor_trainings.present? ? self : previous_revision
  end

  def was_draft?
    claim_record = self
    claim_record = claim_record.previous_revision while claim_record.present? && !claim_record.draft?

    claim_record.nil? ? false : claim_record.draft?
  end

  def self.policy_class
    "ClaimPolicy"
  end

  private

  def has_revision?
    previous_revision_id.present? ||
      id.present? && Claims::Claim.find_by(previous_revision_id: id).present?
  end
end
