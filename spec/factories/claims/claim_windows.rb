# == Schema Information
#
# Table name: claim_windows
#
#  id               :uuid             not null, primary key
#  discarded_at     :date
#  ends_on          :date             not null
#  starts_on        :date             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  academic_year_id :uuid             not null
#
# Indexes
#
#  index_claim_windows_on_academic_year_id  (academic_year_id)
#  index_claim_windows_on_discarded_at      (discarded_at)
#
# Foreign Keys
#
#  fk_rails_...  (academic_year_id => academic_years.id)
#
FactoryBot.define do
  factory :claim_window, class: "Claims::ClaimWindow" do
    trait :current do
      starts_on { 2.days.ago }
      ends_on { 2.days.from_now }
      association :academic_year, :current
    end

    trait :historic do
      starts_on { 2.years.ago }
      ends_on { starts_on + 2.months }
      academic_year { AcademicYear.for_date(starts_on) }
    end

    trait :upcoming do
      starts_on { 2.months.from_now }
      ends_on { 4.months.from_now }
      academic_year { AcademicYear.for_date(starts_on) }
    end
  end
end
