require "rails_helper"

describe DfESignInUser do
  describe ".begin_session!" do
    it "creates a new session for dfe user details" do
      session = {}
      omniauth_payload = {
        "info" => {
          "first_name" => "Example",
          "last_name" => "User",
          "email" => "example_user@example.com",
        },
      }
      DfESignInUser.begin_session!(session, omniauth_payload)

      expect(session).to eq(
        {
          "dfe_sign_in_user" => {
            "first_name" => "Example",
            "last_name" => "User",
            "email" => "example_user@example.com",
          },
        },
      )
    end
  end

  describe ".load_from_session" do
    it "returns a DfESignInUser with details stored in the session" do
      session = {
        "dfe_sign_in_user" => {
          "first_name" => "Example",
          "last_name" => "User",
          "email" => "example_user@example.com",
        },
        "service" => :placements,
      }
      dfe_sign_in_user = DfESignInUser.load_from_session(session)

      expect(dfe_sign_in_user).not_to be_nil
      expect(dfe_sign_in_user.first_name).to eq("Example")
      expect(dfe_sign_in_user.last_name).to eq("User")
      expect(dfe_sign_in_user.email).to eq("example_user@example.com")
    end
  end

  describe "#user" do
    describe "claims service" do
      it "returns the current Claims::User" do
        claims_user = create(:claims_user)

        session = {
          "dfe_sign_in_user" => {
            "first_name" => claims_user.first_name,
            "last_name" => claims_user.last_name,
            "email" => claims_user.email,
          },
          "service" => :claims,
        }

        dfe_sign_in_user = DfESignInUser.load_from_session(session)

        expect(dfe_sign_in_user.user).to eq claims_user
        expect(dfe_sign_in_user.user).to be_a Claims::User
      end
    end

    describe "placements service" do
      it "returns the current Placements::User" do
        placements_user = create(:placements_user)

        session = {
          "dfe_sign_in_user" => {
            "first_name" => placements_user.first_name,
            "last_name" => placements_user.last_name,
            "email" => placements_user.email,
          },
          "service" => :placements,
        }

        dfe_sign_in_user = DfESignInUser.load_from_session(session)

        expect(dfe_sign_in_user.user).to eq placements_user
        expect(dfe_sign_in_user.user).to be_a Placements::User
      end

      it "returns a Placements::SupportUser for support users" do
        support_user = create(:placements_support_user)

        session = {
          "dfe_sign_in_user" => {
            "first_name" => support_user.first_name,
            "last_name" => support_user.last_name,
            "email" => support_user.email,
          },
          "service" => :placements,
        }

        dfe_sign_in_user = DfESignInUser.load_from_session(session)

        expect(dfe_sign_in_user.user.id).to eq support_user.id
        expect(dfe_sign_in_user.user).to be_a Placements::SupportUser
      end
    end
  end

  describe ".end_session" do
    it "clears the session" do
      session = {
        "dfe_sign_in_user" => {
          "first_name" => "Example",
          "last_name" => "User",
          "email" => "example_user@example.com",
        },
      }

      DfESignInUser.end_session!(session)

      expect(session).to eq({})
    end
  end
end
