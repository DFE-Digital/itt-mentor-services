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
#
class Placements::Course < ApplicationRecord
end
