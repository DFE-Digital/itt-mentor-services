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
#  index_users_on_discarded_at    (discarded_at)
#  index_users_on_type_and_email  (type,email) UNIQUE
#
class Claims::User < User
  has_many :schools,
           through: :memberships,
           source: :organisation,
           source_type: "School"
end
