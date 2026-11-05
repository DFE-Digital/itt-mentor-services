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
FactoryBot.define do
  factory :grant_conditions_acceptance, class: "Claims::GrantConditionsAcceptance" do
    association :school, factory: :claims_school, grant_conditions_accepted: false
    association :accepted_by, factory: :claims_user
    academic_year { AcademicYear.current }
    accepted_at { Time.current }
  end
end
