# == Schema Information
#
# Table name: users
#
#  id                        :uuid             not null, primary key
#  first_name                :string           not null
#  last_name                 :string           not null
#  email                     :string           not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  type                      :string
#  dfe_sign_in_uid           :string
#  last_signed_in_at         :datetime
#  discarded_at              :datetime
#  selected_academic_year_id :uuid
#
# Indexes
#
#  index_users_on_selected_academic_year_id        (selected_academic_year_id)
#  index_users_on_type_and_discarded_at_and_email  (type,discarded_at,email)
#  index_users_on_type_and_email                   (type,email) UNIQUE
#

require "rails_helper"

RSpec.describe Claims::ProviderUser do
  describe "associations" do
    describe "#providers" do
      it { is_expected.to have_many(:providers).through(:user_memberships).source(:organisation) }

      it "returns providers linked through memberships" do
        provider_user = create(:claims_provider_user)
        provider_1 = create(:claims_provider)
        provider_2 = create(:claims_provider)

        provider_user.providers << provider_1
        provider_user.providers << provider_2

        expect(provider_user.providers).to contain_exactly(provider_1, provider_2)
      end
    end
  end

  describe "#organisation_count" do
    it "returns the number of providers linked to the user" do
      provider_user = create(:claims_provider_user)
      provider_user.providers << create(:claims_provider)
      provider_user.providers << create(:claims_provider)

      expect(provider_user.organisation_count).to eq(2)
    end
  end
end
