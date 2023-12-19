# == Schema Information
#
# Table name: providers
#
#  id            :uuid             not null, primary key
#  provider_code :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_providers_on_provider_code  (provider_code) UNIQUE
#
require "rails_helper"

RSpec.describe Provider, type: :model do
  context "associations" do
    it { should have_many(:memberships) }
  end

  context "validations" do
    subject { create(:provider) }

    it { is_expected.to validate_presence_of(:provider_code) }
    it do
      is_expected.to validate_uniqueness_of(
        :provider_code,
      ).case_insensitive.with_message("Provider already exists")
    end
  end
end
