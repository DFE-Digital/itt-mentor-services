# == Schema Information
#
# Table name: trainees
#
#  id                :uuid             not null, primary key
#  degree_subject    :string
#  itt_course_code   :string
#  itt_course_uuid   :string
#  study_mode        :string
#  training_provider :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  candidate_id      :string
#  course_id         :uuid
#  provider_id       :uuid
#
# Indexes
#
#  index_trainees_on_course_id    (course_id)
#  index_trainees_on_provider_id  (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#  fk_rails_...  (provider_id => providers.id)
#
class Placements::Trainee < ApplicationRecord
end
