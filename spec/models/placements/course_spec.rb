# == Schema Information
#
# Table name: courses
#
#  id            :uuid             not null, primary key
#  code          :string
#  name          :string
#  subject_codes :string
#  uuid          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  provider_id   :string
#  subject_id    :uuid
#
# Indexes
#
#  index_courses_on_subject_id  (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (subject_id => subjects.id)
#
require "rails_helper"

RSpec.describe Course, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
