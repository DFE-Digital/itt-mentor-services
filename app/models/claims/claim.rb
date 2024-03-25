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
class Claims::Claim < ApplicationRecord
  audited
  has_associated_audits

  belongs_to :school
  belongs_to :provider
  belongs_to :created_by, polymorphic: true
  belongs_to :submitted_by, polymorphic: true, optional: true

  has_many :mentor_trainings
  has_many :mentors, through: :mentor_trainings

  validates :status, presence: true
  validates :reference, uniqueness: { case_sensitive: false }, allow_nil: true

  scope :not_internal, -> { where.not(status: :internal) }
  scope :order_created_at_desc, -> { order(created_at: :desc) }

  enum :status,
       { internal: "internal", draft: "draft", submitted: "submitted" },
       validate: true

  delegate :name, to: :provider, prefix: true, allow_nil: true
  delegate :users, to: :school, prefix: true
  delegate :full_name, to: :submitted_by, prefix: true, allow_nil: true

  def submitted_on
    submitted_at&.to_date
  end

  def amount
    Claims::CalculateAmount.call(claim: self)
  end
end
