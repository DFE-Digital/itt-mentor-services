require "rails_helper"

RSpec.describe UserDecorator do
  describe "#as_form_params" do
    context "when the User's service is Claims" do
      it "returns a hash of form values with a key 'claims_user'" do
        user = create(:claims_user,
                      first_name: "Claims",
                      last_name: "User",
                      email: "claims_user@example.com")
        expect(user.decorate.as_form_params).to eq(
          { "claims_user" => {
            "first_name" => "Claims",
            "last_name" => "User",
            "email" => "claims_user@example.com",
          } },
        )
      end
    end

    context "when the User's service is Placements" do
      it "returns a hash of form values with a key 'placements_user'" do
        user = create(:placements_user,
                      first_name: "Placements",
                      last_name: "User",
                      email: "placements_user@example.com")
        expect(user.decorate.as_form_params).to eq(
          { "placements_user" => {
            "first_name" => "Placements",
            "last_name" => "User",
            "email" => "placements_user@example.com",
          } },
        )
      end
    end
  end
end
