# == Schema Information
#
# Table name: eligibilities
#
#  id               :uuid             not null, primary key
#  claim_window_id  :uuid             not null
#  school_id        :uuid             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  academic_year_id :uuid
#
# Indexes
#
#  index_eligibilities_on_academic_year_id  (academic_year_id)
#  index_eligibilities_on_claim_window_id   (claim_window_id)
#  index_eligibilities_on_school_id         (school_id)
#

FactoryBot.define do
  factory :eligibility, class: Claims::Eligibility do
    claim_window { Claims::ClaimWindow.current || create(:claim_window, :current) }
    academic_year { claim_window.academic_year }
    association :school, factory: :claims_school
  end
end
