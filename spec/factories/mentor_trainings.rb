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

    to_create do |training|
      actor = Claims::AuditContext.actor || training.claim&.submitted_by || training.claim&.created_by
      actor.save! if Claims::AuditContext.actor.nil? && actor&.new_record?
      Claims::AuditContext.set(actor:) { training.save! }
    end

    trait :submitted do
      claim { create(:claim, :submitted) }
    end

    trait :not_assured do
      submitted
      not_assured { true }
      reason_not_assured { "Not assured" }
    end

    trait :rejected do
      not_assured
      rejected { true }
      reason_rejected { "Rejected" }
    end
  end
end
