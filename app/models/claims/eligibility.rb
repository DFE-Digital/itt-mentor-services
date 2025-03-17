# == Schema Information
#
# Table name: eligibilities
#
#  id              :uuid             not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  claim_window_id :uuid             not null
#  school_id       :uuid             not null
#
# Indexes
#
#  index_eligibilities_on_claim_window_id  (claim_window_id)
#  index_eligibilities_on_school_id        (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (claim_window_id => claim_windows.id)
#  fk_rails_...  (school_id => schools.id)
#
class Claims::Eligibility < ApplicationRecord
  belongs_to :school
  belongs_to :claim_window

  delegate :academic_year, to: :claim_window
end
