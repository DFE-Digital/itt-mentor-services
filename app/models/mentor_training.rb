# == Schema Information
#
# Table name: mentor_trainings
#
#  id              :uuid             not null, primary key
#  date_completed  :datetime
#  hours_completed :integer
#  training_type   :enum
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  claim_id        :uuid
#  mentor_id       :uuid
#  provider_id     :uuid
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
class MentorTraining < ApplicationRecord
  belongs_to :claim
  belongs_to :mentor, optional: true
  belongs_to :provider, optional: true
end
