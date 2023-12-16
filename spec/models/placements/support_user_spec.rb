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

RSpec.describe Placements::SupportUser do
  describe "default scope" do
    let(:email) { "same_email@email.co.uk" }
    let!(:support_user_with_placements_service) do
      create(:placements_user, :support, email:)
    end
    let!(:support_user_with_claims_service) do
      create(:claims_user, :support, email:)
    end

    it "is scoped to placement support users" do
      user = described_class.find(support_user_with_placements_service.id)
      expect(described_class.all).to contain_exactly(user)
    end
  end
end
