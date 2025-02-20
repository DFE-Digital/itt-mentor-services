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
class Placements::Course < ApplicationRecord
end
