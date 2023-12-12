# == Schema Information
#
# Table name: users
#
#  id         :uuid             not null, primary key
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
RSpec.describe Persona, type: :model do
  describe "validations" do
    subject { create(:persona) }
    it { is_expected.to validate_inclusion_of(:email).in_array(PERSONA_EMAILS) }
  end
end
