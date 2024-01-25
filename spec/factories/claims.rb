# == Schema Information
#
# Table name: claims
#
#  id         :uuid             not null, primary key
#  draft      :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :uuid             not null
#
# Indexes
#
#  index_claims_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
FactoryBot.define do
  factory :claim do
    association :school
  end
end
