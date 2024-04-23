# == Schema Information
#
# Table name: claims
#
#  id                   :uuid             not null, primary key
#  created_by_type      :string
#  reference            :string
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
class Claims::Claim < ApplicationRecord
  audited
  has_associated_audits

  belongs_to :school
  belongs_to :provider
  belongs_to :created_by, polymorphic: true
  belongs_to :submitted_by, polymorphic: true, optional: true

  has_many :mentor_trainings, dependent: :destroy
  has_many :mentors, through: :mentor_trainings

  belongs_to :previous_revision, class_name: "Claims::Claim", optional: true
  belongs_to :next_revision, class_name: "Claims::Claim", optional: true

  validates :status, presence: true
  validates(
    :reference,
    uniqueness: { case_sensitive: false },
    allow_nil: true,
    unless: :has_revision?,
  )

  VISIBLE_STATUSES = %i[draft submitted].freeze

  scope :visible, -> { where(status: VISIBLE_STATUSES) }
  scope :order_created_at_desc, -> { order(created_at: :desc) }

  enum :status,
       { internal_draft: "internal_draft", draft: "draft", submitted: "submitted" },
       validate: true

  delegate :name, to: :provider, prefix: true, allow_nil: true
  delegate :users, to: :school, prefix: true
  delegate :full_name, to: :submitted_by, prefix: true, allow_nil: true

  def submitted_on
    submitted_at&.to_date
  end

  def amount
    Claims::Claim::CalculateAmount.call(claim: self)
  end

  def ready_to_be_checked?
    mentors.present? && mentor_trainings.without_hours.blank?
  end

  def get_valid_revision
    claim_record = self
    Claims::Claim::RemoveEmptyMentorTrainingHours.call(claim: claim_record)

    claim_record = claim_record.previous_revision while claim_record.present? && !claim_record.ready_to_be_checked?

    claim_record
  end

  def deep_dup
    dup_record = dup
    dup_record.created_by = created_by
    dup_record.submitted_by = submitted_by
    dup_record.mentor_trainings = mentor_trainings.map(&:dup)
    dup_record.previous_revision_id = id
    dup_record.status = :internal_draft
    dup_record
  end

  def create_revision!
    dup = deep_dup

    ActiveRecord::Base.transaction do
      dup.save!
      update!(next_revision_id: dup.id)
    end

    dup
  end

  def has_revision?
    previous_revision_id.present? || next_revision_id.present?
  end

  def was_draft?
    claim_record = self

    claim_record = claim_record.previous_revision while claim_record.present? && !claim_record.draft?

    claim_record&.draft?
  end
end
