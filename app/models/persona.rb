# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  email      :string           not null
#  first_name :string           not null
#  last_name  :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class Persona < User
  default_scope { where(email: PERSONA_EMAILS) }
  validates :email, inclusion: { in: PERSONA_EMAILS }
end
