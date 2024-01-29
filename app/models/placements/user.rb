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
class Placements::User < User
  has_many :schools,
           -> { placements_service },
           through: :memberships,
           source: :organisation,
           source_type: "School"
  has_many :providers,
           -> { placements_service },
           through: :memberships,
           source: :organisation,
           source_type: "Provider"
end
