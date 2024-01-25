# == Schema Information
#
# Table name: users
#
#  id         :uuid             not null, primary key
#  email      :string           not null
#  first_name :string           not null
#  last_name  :string           not null
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_type_and_email  (type,email) UNIQUE
#
class User < ApplicationRecord
  has_many :memberships

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :type, presence: true
  validates :email, uniqueness: { scope: :type, case_sensitive: false }

  scope :claims, -> { where(type: "Claims::User") }
  scope :placements, -> { where(type: "Placements::User") }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def is_support_user?
    false
  end
end
