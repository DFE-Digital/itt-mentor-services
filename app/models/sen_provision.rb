# == Schema Information
#
# Table name: sen_provisions
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sen_provisions_on_name  (name) UNIQUE
#
class SENProvision < ApplicationRecord
  has_many :school_sen_provisions
  has_many :schools, through: :school_sen_provisions

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
