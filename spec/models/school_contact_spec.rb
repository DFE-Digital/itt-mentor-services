# == Schema Information
#
# Table name: school_contacts
#
#  id            :uuid             not null, primary key
#  email_address :string
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
require 'rails_helper'

RSpec.describe SchoolContact, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
