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
  end

  describe "#placements_support_organisation_path" do
    context "when organisation is a school" do
      it "returns the support school path" do
        organisation = create(:school)
        expect(placements_support_organisation_path(organisation)).to eq(placements_support_school_path(organisation))
      end
    end

    context "when organisation is a provider" do
      it "returns the support provider path" do
        organisation = create(:provider)
        expect(placements_support_organisation_path(organisation)).to eq(placements_support_provider_path(organisation))
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
  end

  describe "#placements_organisation_path" do
    context "when organisation is a school" do
      it "returns the school placements path" do
        organisation = create(:school)
        expect(placements_organisation_path(organisation)).to eq(placements_school_placements_path(organisation))
      end
    end

    context "when organisation is a provider" do
      it "returns the provider path" do
        organisation = create(:provider)
        expect(placements_organisation_path(organisation)).to eq(placements_provider_path(organisation))
      end
    end

    context "when organisation is not a school or provider" do
      it "raises NotImplementedError" do
        organisation = create(:placements_user)
        expect { placements_organisation_path(organisation) }.to raise_error(NotImplementedError)
      end
    end
  end

  describe "#placements_support_users_path" do
    context "when organisation is a school" do
      it "returns the support school users path" do
        organisation = create(:school)
        expect(placements_support_users_path(organisation)).to eq(placements_support_school_users_path(organisation))
      end
    end

    context "when organisation is a provider" do
      it "returns the support provider users path" do
        organisation = create(:provider)
        expect(placements_support_users_path(organisation)).to eq(placements_support_provider_users_path(organisation))
      end
    end
  end

  describe "#check_placements_organisation_users_path" do
    context "when organisation is a school" do
      it "returns the check school users path" do
        organisation = create(:school)
        expect(check_placements_organisation_users_path(organisation)).to eq(check_placements_school_users_path(organisation))
      end
    end

    context "when organisation is a provider" do
      it "returns the check provider users path" do
        organisation = create(:provider)
        expect(check_placements_organisation_users_path(organisation)).to eq(check_placements_provider_users_path(organisation))
      end
    end
  end

  describe "#placements_organisation_users_path" do
    context "when organisation is a school" do
      it "returns the school users path" do
        organisation = create(:school)
        expect(placements_organisation_users_path(organisation)).to eq(placements_school_users_path(organisation))
      end
    end

    context "when organisation is a provider" do
      it "returns the provider users path" do
        organisation = create(:provider)
        expect(placements_organisation_users_path(organisation)).to eq(placements_provider_users_path(organisation))
      end
    end
  end

  describe "#new_placements_organisation_user_path" do
    let(:params) { { foo: "bar" } }

    context "when organisation is a school" do
      it "returns the new school user path" do
        organisation = create(:school)
        expect(new_placements_organisation_user_path(organisation, params)).to eq(new_placements_school_user_path(organisation, params))
      end
    end

    context "when organisation is a provider" do
      it "returns the new provider user path" do
        organisation = create(:provider)
        expect(new_placements_organisation_user_path(organisation, params)).to eq(new_placements_provider_user_path(organisation, params))
      end
    end
  end
end
