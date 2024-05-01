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
#  reviewed             :boolean          default(FALSE)
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
class Claims::Claim < ApplicationRecord
  MAXIMUM_CLAIMABLE_HOURS = 20
  audited
  has_associated_audits

  belongs_to :school
  belongs_to :provider
  belongs_to :created_by, polymorphic: true
  belongs_to :submitted_by, polymorphic: true, optional: true

  has_many :mentor_trainings, dependent: :destroy
  has_many :mentors, through: :mentor_trainings

  validates :status, presence: true
  validates :reference, uniqueness: { case_sensitive: false }, allow_nil: true

  ACTIVE_STATUSES = %i[draft submitted].freeze

  scope :active, -> { where(status: ACTIVE_STATUSES) }
  scope :order_created_at_desc, -> { order(created_at: :desc) }

  enum :status,
       { internal_draft: "internal_draft", draft: "draft", submitted: "submitted" },
       validate: true

  delegate :name, to: :provider, prefix: true, allow_nil: true
  delegate :users, to: :school, prefix: true
  delegate :full_name, to: :submitted_by, prefix: true, allow_nil: true

  def valid_mentor_training_hours?
    mentor_trainings_without_current_claim = Claims::MentorTraining.joins(:claim).merge(Claims::Claim.active).where(
      mentor_id: mentor_trainings.select(:mentor_id),
      provider_id:,
    ).where.not(claim_id: id)
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
end
