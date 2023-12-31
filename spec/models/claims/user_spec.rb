# == Schema Information
#
# Table name: users
#
#  id           :uuid             not null, primary key
#  email        :string           not null
#  first_name   :string           not null
#  last_name    :string           not null
#  service      :enum             not null
#  support_user :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_users_on_service_and_email  (service,email) UNIQUE
#
require "rails_helper"

RSpec.describe Claims::User do
  describe "default scope" do
    let(:email) { "same_email@email.co.uk" }
    let!(:user_with_claims_service) { create(:claims_user, email:) }
    let!(:user_with_placements_service) { create(:placements_user, email:) }

    it "is scoped to users of the claims service" do
      user = described_class.find(user_with_claims_service.id)
      expect(described_class.all).to contain_exactly(user)
    end
  end
end
