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

  has_many :schools,   through: :memberships, source: :organisation, source_type: "School"
  has_many :providers, through: :memberships, source: :organisation, source_type: "Provider"

  enum :service, { no_service: "no_service", claims: "claims", placements: "placements" }, validate: true

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :service, presence: true
  validates :email, uniqueness: { scope: :service, case_sensitive: false }

  scope :support_users, -> { where(support_user: true) }
end
