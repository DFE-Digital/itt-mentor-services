# == Schema Information
#
# Table name: mentors
#
#  id         :uuid             not null, primary key
#  first_name :string           not null
#  last_name  :string           not null
#  trn        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Mentor < ApplicationRecord
  has_many :mentor_memberships
  has_many :schools, through: :mentor_memberships

  validates :first_name, :last_name, :trn, presence: true

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
