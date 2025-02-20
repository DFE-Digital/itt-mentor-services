# == Schema Information
#
# Table name: trainees
#
#  id                     :uuid             not null, primary key
#  itt_course_code        :string
#  study_mode             :string
#  training_provider_code :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  candidate_id           :string
#
require "rails_helper"

RSpec.describe Trainee, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
