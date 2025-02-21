# == Schema Information
#
# Table name: courses
#
#  id            :uuid             not null, primary key
#  code          :string
#  subject_codes :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require "rails_helper"

RSpec.describe Course, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
