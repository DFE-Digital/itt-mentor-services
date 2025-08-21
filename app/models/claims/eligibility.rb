# == Schema Information
#
# Table name: eligibilities
#
#  id               :uuid             not null, primary key
#  school_id        :uuid             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  academic_year_id :uuid
#
# Indexes
#
#  index_eligibilities_on_academic_year_id  (academic_year_id)
#  index_eligibilities_on_school_id         (school_id)
#

class Claims::Eligibility < ApplicationRecord
  belongs_to :school
  belongs_to :academic_year
  has_many :claim_windows, through: :academic_year
end
