require "rails_helper"

RSpec.describe "Claims::Schools", service: :claims, type: :request do
  describe "GET /schools/:id" do
    let(:school) { create(:school, :claims, name: "My School") }
    let(:other_school) { create(:school, :claims, name: "Other School") }

    context "when the user is a member of the school" do
      it "returns a successful response" do
        user = create(:claims_user)
        create(:user_membership, user:, organisation: school)
        sign_in_as user

        get claims_school_path(school)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when the user is not a member of the school" do
      it "does not allow access to another school" do
        user = create(:claims_user)
        create(:user_membership, user:, organisation: school)
        sign_in_as user

        expect { get claims_school_path(other_school) }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "when the user is a support user" do
      it "can access any school" do
        sign_in_as create(:claims_support_user)

        get claims_school_path(other_school)

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
