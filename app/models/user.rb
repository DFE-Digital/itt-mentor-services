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

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def support_user?
    false
  end

  # Extracts the namespace of the class as a symbol to determine the service
  # e.g.
  # - Placements::User => :placements
  # - Claims::User => :claims
  def service
    self.class.name.deconstantize.downcase.to_sym
  end
end
