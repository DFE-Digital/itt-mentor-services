# == Schema Information
#
# Table name: school_contacts
#
#  id            :uuid             not null, primary key
#  email_address :string           not null
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  school_id     :uuid             not null
#
# Indexes
#
#  index_school_contacts_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
class Placements::SchoolContact < ApplicationRecord
  belongs_to :school
  before_destroy :prevent_destroy

  normalizes :name, with: ->(value) { value.strip }
  normalizes :email_address, with: ->(value) { value.strip.downcase }

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  def prevent_destroy
    raise ActiveRecord::RecordNotDestroyed,
          I18n.t(
            "activerecord.errors.models.placements/school_contact.can_not_be_destroyed",
          )
  end
end
