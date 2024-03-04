# == Schema Information
#
# Table name: users
#
#  id                :uuid             not null, primary key
#  dfe_sign_in_uid   :string
#  discarded_at      :datetime
#  email             :string           not null
#  first_name        :string           not null
#  last_name         :string           not null
#  last_signed_in_at :datetime
#  type              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_users_on_type_and_discarded_at_and_email  (type,discarded_at,email)
#  index_users_on_type_and_email                   (type,email) UNIQUE
#
class User < ApplicationRecord
  include Discard::Model

  has_many :user_memberships, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, unless: :support_user?
  validates :type, presence: true
  validates :email, uniqueness: { scope: :type, case_sensitive: false }

  default_scope -> { kept }
  scope :order_by_full_name, -> { order(:first_name, :last_name) }

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
