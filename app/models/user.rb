# == Schema Information
#
# Table name: users
#
#  id           :uuid             not null, primary key
#  email        :string           not null
#  first_name   :string           not null
#  last_name    :string           not null
#  service      :enum             not null
#  support_user :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_users_on_service_and_email  (service,email) UNIQUE
#
class User < ApplicationRecord
  has_many :memberships

  enum :service,
       { no_service: "no_service", claims: "claims", placements: "placements" },
       validate: true

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :service, presence: true
  validates :email, uniqueness: { scope: :service, case_sensitive: false }

  scope :support_users, -> { where(support_user: true) }

  def full_name
    "#{first_name} #{last_name}".strip
  end
end
