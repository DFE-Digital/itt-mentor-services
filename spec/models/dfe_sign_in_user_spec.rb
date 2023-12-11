# frozen_string_literal: true

require "rails_helper"

describe DfESignInUser do
  describe ".begin_session!" do
    it "creates a new session for dfe user details" do
      session = {}
      omniauth_payload = {
        "info" => {
          "first_name" => "Example",
          "last_name" => "User",
          "email" => "example_user@example.com"
        }
      }
      DfESignInUser.begin_session!(session, omniauth_payload)

      expect(session).to eq({
        "dfe_sign_in_user" => {
          "first_name" => "Example",
          "last_name" => "User",
          "email" => "example_user@example.com"
        }
      })
    end
  end

  describe ".load_from_session" do
    it "returns a DfESignInUser with details stored in the session" do
      session = { "dfe_sign_in_user" => {
          "first_name" => "Example",
          "last_name" => "User",
          "email" => "example_user@example.com"
        }
      }
      user = DfESignInUser.load_from_session(session)
      
      expect(user).not_to be_nil
      expect(user.first_name).to eq("Example")
      expect(user.last_name).to eq("User")
      expect(user.email).to eq("example_user@example.com")
    end
  end

  describe ".end_session" do
    it "clears the session" do
      session = { "dfe_sign_in_user" => {
          "first_name" => "Example",
          "last_name" => "User",
          "email" => "example_user@example.com"
        }
      }

      DfESignInUser.end_session!(session)

      expect(session).to eq({})
    end
  end
end
