# == Schema Information
#
# Table name: provider_email_addresses
#
#  id            :uuid             not null, primary key
#  email_address :string
#  primary       :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  provider_id   :uuid             not null
#
# Indexes
#
#  index_provider_email_addresses_on_primary      (primary)
#  index_provider_email_addresses_on_provider_id  (provider_id)
#  unique_provider_email                          (email_address,provider_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#
require "rails_helper"

RSpec.describe ProviderEmailAddress, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:provider) }
  end

  describe "validations" do
    subject(:test_provider_email_address) { build(:provider_email_address) }

    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_uniqueness_of(:email_address).scoped_to(:provider_id).case_insensitive }
  end
end
