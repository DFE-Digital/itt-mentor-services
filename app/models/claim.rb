# == Schema Information
#
# Table name: claims
#
#  id           :uuid             not null, primary key
#  draft        :boolean          default(FALSE)
#  reference    :string
#  submitted_at :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  provider_id  :uuid
#  school_id    :uuid             not null
#
# Indexes
#
#  index_claims_on_provider_id  (provider_id)
#  index_claims_on_reference    (reference) UNIQUE
#  index_claims_on_school_id    (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#
class Claim < ApplicationRecord
  belongs_to :school
  belongs_to :provider

  has_many :mentor_trainings
  has_many :mentors, through: :mentor_trainings

  validates :reference, uniqueness: true, allow_nil: true

  delegate :name, to: :provider, prefix: true, allow_nil: true

  def submitted_on
    submitted_at&.to_date
  end

  def amount
    Claims::CalculateAmount.call(claim: self)
  end
end
