# == Schema Information
#
# Table name: samplings
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Claims::Sampling < ApplicationRecord
  has_many :provider_samplings
  has_many :claims, through: :provider_samplings
end
