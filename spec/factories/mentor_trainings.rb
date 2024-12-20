# == Schema Information
#
# Table name: mentor_trainings
#
#  id                 :uuid             not null, primary key
#  date_completed     :datetime
#  hours_clawed_back  :integer
#  hours_completed    :integer
#  not_assured        :boolean          default(FALSE)
#  reason_clawed_back :text
#  reason_not_assured :text
#  reason_rejected    :text
#  rejected           :boolean          default(FALSE)
#  training_type      :enum             default("initial"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  claim_id           :uuid
#  mentor_id          :uuid
#  provider_id        :uuid
#
# Indexes
#
#  index_mentor_trainings_on_claim_id     (claim_id)
#  index_mentor_trainings_on_mentor_id    (mentor_id)
#  index_mentor_trainings_on_provider_id  (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (claim_id => claims.id)
#  fk_rails_...  (mentor_id => mentors.id)
#  fk_rails_...  (provider_id => providers.id)
#
FactoryBot.define do
  factory :mentor_training, class: "Claims::MentorTraining" do
    association :claim
    association :mentor, factory: :claims_mentor
    association :provider, factory: :claims_provider

    trait :submitted do
      claim { create(:claim, :submitted) }
    end
  end
end
