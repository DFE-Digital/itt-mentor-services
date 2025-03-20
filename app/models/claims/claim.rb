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
class Claims::Claim < ApplicationRecord
  audited
  has_associated_audits

  belongs_to :school
  belongs_to :provider
  belongs_to :claim_window
  belongs_to :created_by, polymorphic: true
  belongs_to :submitted_by, polymorphic: true, optional: true
  belongs_to :support_user, class_name: "Claims::SupportUser", optional: true

  has_one :academic_year, through: :claim_window

  has_many :mentor_trainings, dependent: :destroy
  has_many :mentors, through: :mentor_trainings
  has_many :provider_sampling_claims, dependent: :destroy
  has_many :provider_samplings, through: :provider_sampling_claims
  has_many :clawback_claims, dependent: :destroy

  accepts_nested_attributes_for :mentor_trainings

  validates :status, presence: true
  validates(
    :reference,
    uniqueness: { case_sensitive: false },
    allow_nil: true,
  )

  ACTIVE_STATUSES = %i[draft submitted].freeze
  DRAFT_STATUSES = %i[internal_draft draft].freeze
  PAYMENT_ACTIONABLE_STATUSES = %w[payment_information_requested payment_information_sent].freeze
  SAMPLING_STATUSES = %w[sampling_in_progress sampling_provider_not_approved].freeze
  CLAWBACK_STATUSES = %w[clawback_requested clawback_in_progress sampling_not_approved].freeze

  scope :active, -> { where(status: ACTIVE_STATUSES) }
  scope :order_created_at_desc, -> { order(created_at: :desc) }
  scope :not_draft_status, -> { where.not(status: DRAFT_STATUSES) }
  scope :paid_for_current_academic_year, lambda {
    paid.joins(claim_window: :academic_year)
    .where(academic_years: { id: AcademicYear.for_date(Date.current).id })
  }

  enum :status,
       {
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
       },
       validate: true

  delegate :name, :primary_email_address, to: :provider, prefix: true, allow_nil: true
  delegate :urn, :postcode, :region_funding_available_per_hour, to: :school, prefix: true, allow_nil: true
  delegate :name, :users, to: :school, prefix: true
  delegate :full_name, to: :submitted_by, prefix: true, allow_nil: true
  delegate :name, :ends_on, to: :academic_year, prefix: true, allow_nil: true

  def valid_mentor_training_hours?
    mentor_trainings.all? do |mentor_training|
      training_allowance = Claims::TrainingAllowance.new(mentor: mentor_training.mentor, provider:, academic_year:)
      training_allowance.remaining_hours >= mentor_training.hours_completed
    end
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

  def total_clawback_amount
    mentor_trainings.not_assured.sum { |mt| mt.hours_clawed_back * school.region_funding_available_per_hour }
  end

  def in_draft?
    return true if status.nil?

    DRAFT_STATUSES.include?(status.to_sym)
  end

  def in_clawback?
    %w[clawback_requested clawback_in_progress clawback_complete].include?(status)
  end

  def amount_after_clawback
    amount - total_clawback_amount
  end

  def total_hours_completed
    mentor_trainings.sum(&:hours_completed)
  end

  def payment_actionable?
    PAYMENT_ACTIONABLE_STATUSES.include?(status)
  end
end
