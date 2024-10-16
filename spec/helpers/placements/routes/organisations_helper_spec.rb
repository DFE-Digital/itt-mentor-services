require "rails_helper"

RSpec.describe Placements::Routes::OrganisationsHelper do
  describe "#organisation_users_path" do
    context "when organisation is a school" do
      it "returns the school users path" do
        organisation = create(:school)
        expect(organisation_users_path(organisation)).to eq(placements_school_users_path(organisation))
      end
    end

    context "when organisation is a provider" do
      it "returns the provider users path" do
        organisation = create(:provider)
        expect(organisation_users_path(organisation)).to eq(placements_provider_users_path(organisation))
      end
    end

    context "when organisation is not a school or provider" do
      it "raises NotImplementedError" do
        organisation = create(:claim)
        expect { organisation_users_path(organisation) }.to raise_error(NotImplementedError)
      end
    end
  end

  describe "#placements_organisation_user_path" do
    context "when organisation is a school" do
      it "returns the school user path" do
        organisation = create(:school)
        user = create(:user, type: "Placements::User")
        expect(placements_organisation_user_path(organisation, user)).to eq(placements_school_user_path(organisation, user))
      end
    end

    context "when organisation is a provider" do
      it "returns the provider user path" do
        organisation = create(:provider)
        user = create(:user, type: "Placements::User")
        expect(placements_organisation_user_path(organisation, user)).to eq(placements_provider_user_path(organisation, user))
      end
    end

    context "when organisation is not a school or provider" do
      it "raises NotImplementedError" do
        organisation = create(:claim)
        user = create(:user, type: "Placements::User")
        expect { placements_organisation_user_path(organisation, user) }.to raise_error(NotImplementedError)
      end
    end
  end
end
