# == Schema Information
#
# Table name: provider_courses
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Placements::ProviderCourse < ApplicationRecord
  belongs_to :provider
  belongs_to :course
end
