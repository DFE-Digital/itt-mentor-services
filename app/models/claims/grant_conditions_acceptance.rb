# == Schema Information
#
# Table name: grant_conditions_acceptances
#
#  id               :uuid             not null, primary key
#  accepted_at      :datetime         not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  academic_year_id :uuid             not null
#  accepted_by_id   :uuid             not null
#  school_id        :uuid             not null
#
# Indexes
#
#  index_grant_conditions_acceptances_on_academic_year_id          (academic_year_id)
#  index_grant_conditions_acceptances_on_accepted_by_id            (accepted_by_id)
#  index_grant_conditions_acceptances_on_school_and_academic_year  (school_id,academic_year_id) UNIQUE
#  index_grant_conditions_acceptances_on_school_id                 (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (academic_year_id => academic_years.id)
#  fk_rails_...  (accepted_by_id => users.id)
#  fk_rails_...  (school_id => schools.id) ON DELETE => cascade
#
class Claims::GrantConditionsAcceptance < ApplicationRecord
  belongs_to :school, class_name: "Claims::School"
  belongs_to :academic_year
  belongs_to :accepted_by, -> { with_discarded }, class_name: "::User"

  validates :accepted_at, presence: true
  validates :school_id, uniqueness: { scope: :academic_year_id }

  scope :order_by_latest, -> { order(accepted_at: :desc) }
end
