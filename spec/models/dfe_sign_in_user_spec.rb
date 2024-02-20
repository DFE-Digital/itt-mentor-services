require "rails_helper"

describe DfESignInUser do
  describe ".begin_session!" do
    it "creates a new session for dfe user details" do
      Timecop.freeze do
        session = {}
        omniauth_payload = {
          "info" => {
            "first_name" => "Example",
            "last_name" => "User",
            "email" => "example_user@example.com",
          },
          "uid" => "123",
          "dfe_sign_in_uid" => "123",
          "credentials" => { "id_token" => "123" },
          "provider" => "dfe",
        }
        described_class.begin_session!(session, omniauth_payload)

        expect(session).to eq(
          {
            "dfe_sign_in_user" => {
              "first_name" => "Example",
              "last_name" => "User",
              "email" => "example_user@example.com",
              "dfe_sign_in_uid" => "123",
              "last_active_at" => Time.current,
              "id_token" => "123",
              "provider" => "dfe",
            },
          },
        )
      end
    end
  end

  describe ".load_from_session" do
    it "returns a DfESignInUser with details stored in the session" do
      session = {
        "dfe_sign_in_user" => {
          "first_name" => "Example",
          "last_name" => "User",
          "email" => "example_user@example.com",
          "last_active_at" => 1.hour.ago,
          "dfe_sign_in_uid" => "123",
          "id_token" => "123",
          "provider" => "dfe",
        },
      }
      dfe_sign_in_user = described_class.load_from_session(session, service: :placements)

      expect(dfe_sign_in_user).not_to be_nil
      expect(dfe_sign_in_user.first_name).to eq("Example")
      expect(dfe_sign_in_user.last_name).to eq("User")
      expect(dfe_sign_in_user.email).to eq("example_user@example.com")
      expect(dfe_sign_in_user.dfe_sign_in_uid).to eq("123")
      expect(dfe_sign_in_user.id_token).to eq("123")
      expect(dfe_sign_in_user.provider).to eq("dfe")
    end

    context "when last_active_at is older than 2 hours" do
      it "returns nil" do
        session = {
          "dfe_sign_in_user" => {
            "last_active_at" => 3.hours.ago,
          },
        }
        dfe_sign_in_user = described_class.load_from_session(session, service: :placements)

        expect(dfe_sign_in_user).to be_nil
      end
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
            "last_active_at" => 1.hour.ago,
            "dfe_sign_in_uid" => "123",
            "id_token" => "123",
            "provider" => nil,
          },
        }

        dfe_sign_in_user = described_class.load_from_session(session, service: :claims)

        expect(dfe_sign_in_user.user).to eq claims_user
        expect(dfe_sign_in_user.user).to be_a Claims::User
      end

      it "returns a Claims::SupportUser for support users" do
        support_user = create(:claims_support_user)

        session = {
          "dfe_sign_in_user" => {
            "first_name" => support_user.first_name,
            "last_name" => support_user.last_name,
            "email" => support_user.email,
            "last_active_at" => 1.hour.ago,
            "dfe_sign_in_uid" => "123",
            "id_token" => "123",
            "provider" => nil,
          },
        }

        dfe_sign_in_user = described_class.load_from_session(session, service: :claims)

        expect(dfe_sign_in_user.user.id).to eq support_user.id
        expect(dfe_sign_in_user.user).to be_a Claims::SupportUser
      end

      context "with DFE provider" do
        it "returns the current Claims::User by dfe_sign_in_uid" do
          claims_user = create(:claims_user)

          session = {
            "dfe_sign_in_user" => {
              "first_name" => claims_user.first_name,
              "last_name" => claims_user.last_name,
              "email" => "test@email.com",
              "last_active_at" => 1.hour.ago,
              "dfe_sign_in_uid" => claims_user.dfe_sign_in_uid,
              "id_token" => "123",
              "provider" => "dfe",
            },
          }

          dfe_sign_in_user = described_class.load_from_session(session, service: :claims)

          expect(dfe_sign_in_user.user).to eq claims_user
          expect(dfe_sign_in_user.user).to be_a Claims::User
        end

        it "returns the current Claims::User by email" do
          claims_user = create(:claims_user)

          session = {
            "dfe_sign_in_user" => {
              "first_name" => claims_user.first_name,
              "last_name" => claims_user.last_name,
              "email" => claims_user.email,
              "last_active_at" => 1.hour.ago,
              "dfe_sign_in_uid" => "123",
              "id_token" => "123",
              "provider" => nil,
            },
          }

          dfe_sign_in_user = described_class.load_from_session(session, service: :claims)

          expect(dfe_sign_in_user.user).to eq claims_user
          expect(dfe_sign_in_user.user).to be_a Claims::User
        end

        it "returns a Claims::SupportUser for support users" do
          support_user = create(:claims_support_user)

          session = {
            "dfe_sign_in_user" => {
              "first_name" => support_user.first_name,
              "last_name" => support_user.last_name,
              "email" => support_user.email,
              "last_active_at" => 1.hour.ago,
              "dfe_sign_in_uid" => support_user.dfe_sign_in_uid,
              "id_token" => "123",
              "provider" => nil,
            },
          }

          dfe_sign_in_user = described_class.load_from_session(session, service: :claims)

          expect(dfe_sign_in_user.user.id).to eq support_user.id
          expect(dfe_sign_in_user.user).to be_a Claims::SupportUser
        end
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
            "last_active_at" => 1.hour.ago,
            "dfe_sign_in_uid" => "123",
            "id_token" => "123",
            "provider" => nil,
          },
        }

        dfe_sign_in_user = described_class.load_from_session(session, service: :placements)

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
            "last_active_at" => 1.hour.ago,
            "dfe_sign_in_uid" => "123",
            "id_token" => "123",
            "provider" => nil,
          },
        }

        dfe_sign_in_user = described_class.load_from_session(session, service: :placements)

        expect(dfe_sign_in_user.user.id).to eq support_user.id
        expect(dfe_sign_in_user.user).to be_a Placements::SupportUser
      end

      context "with DFE provider" do
        it "returns the current Placements::User by dfe_sign_in_uid" do
          placements_user = create(:placements_user)

          session = {
            "dfe_sign_in_user" => {
              "first_name" => placements_user.first_name,
              "last_name" => placements_user.last_name,
              "email" => "test@email.com",
              "last_active_at" => 1.hour.ago,
              "dfe_sign_in_uid" => placements_user.dfe_sign_in_uid,
              "id_token" => "123",
              "provider" => "dfe",
            },
          }

          dfe_sign_in_user = described_class.load_from_session(session, service: :placements)

          expect(dfe_sign_in_user.user).to eq placements_user
          expect(dfe_sign_in_user.user).to be_a Placements::User
        end

        it "returns the current Placements::User by email" do
          placements_user = create(:placements_user)

          session = {
            "dfe_sign_in_user" => {
              "first_name" => placements_user.first_name,
              "last_name" => placements_user.last_name,
              "email" => placements_user.email,
              "last_active_at" => 1.hour.ago,
              "dfe_sign_in_uid" => "123",
              "id_token" => "123",
              "provider" => "dfe",
            },
          }

          dfe_sign_in_user = described_class.load_from_session(session, service: :placements)

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
              "last_active_at" => 1.hour.ago,
              "dfe_sign_in_uid" => support_user.dfe_sign_in_uid,
              "id_token" => "123",
              "provider" => "dfe",
            },
          }

          dfe_sign_in_user = described_class.load_from_session(session, service: :placements)

          expect(dfe_sign_in_user.user.id).to eq support_user.id
          expect(dfe_sign_in_user.user).to be_a Placements::SupportUser
        end
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
          "last_active_at" => 1.hour.ago,
          "dfe_sign_in_uid" => "123",
          "id_token" => "123",
          "provider" => nil,
        },
      }

      described_class.end_session!(session)

      expect(session).to eq({})
    end
  end
end
