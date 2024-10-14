require "rails_helper"

RSpec.describe SupportUserConstraint do
  let!(:claims_support_user) { create(:claims_support_user) }
  let!(:claims_user) { create(:claims_user) }
  let!(:placements_support_user) { create(:placements_support_user) }
  let!(:placements_user) { create(:placements_user) }
  let(:request) { Struct.new(:session).new({}) }

  describe ".matches?" do
    context "when current service is claims" do
      context "when the user is a claims support user" do
        it "returns true" do
          allow(HostingEnvironment).to receive(:current_service).and_return(:claims)
          allow(DfESignInUser).to receive(:load_from_session).and_return(
            DfESignInUser.new(
              dfe_sign_in_uid: 123,
              email: claims_support_user.email,
              first_name: claims_support_user.first_name,
              last_name: claims_support_user.last_name,
              service: :claims,
            ),
          )
          expect(described_class.new.matches?(request)).to be(true)
        end
      end

      context "when the user is a placements support user" do
        it "returns nil" do
          allow(HostingEnvironment).to receive(:current_service).and_return(:claims)
          allow(DfESignInUser).to receive(:load_from_session).and_return(
            DfESignInUser.new(
              dfe_sign_in_uid: 123,
              email: placements_support_user.email,
              first_name: placements_support_user.first_name,
              last_name: placements_support_user.last_name,
              service: :claims,
            ),
          )
          expect(described_class.new.matches?(request)).to be_nil
        end
      end

      context "when the user is a claims user" do
        it "returns true" do
          allow(HostingEnvironment).to receive(:current_service).and_return(:claims)
          allow(DfESignInUser).to receive(:load_from_session).and_return(
            DfESignInUser.new(
              dfe_sign_in_uid: 123,
              email: claims_user.email,
              first_name: claims_user.first_name,
              last_name: claims_user.last_name,
              service: :claims,
            ),
          )
          expect(described_class.new.matches?(request)).to be(false)
        end
      end

      context "when the user is a placements user" do
        it "returns true" do
          allow(HostingEnvironment).to receive(:current_service).and_return(:claims)
          allow(DfESignInUser).to receive(:load_from_session).and_return(
            DfESignInUser.new(
              dfe_sign_in_uid: 123,
              email: placements_user.email,
              first_name: placements_user.first_name,
              last_name: placements_user.last_name,
              service: :claims,
            ),
          )
          expect(described_class.new.matches?(request)).to be_nil
        end
      end
    end

    context "when the current service is placements" do
      context "when the user is a placements support user" do
        it "returns nil" do
          allow(HostingEnvironment).to receive(:current_service).and_return(:placements)
          allow(DfESignInUser).to receive(:load_from_session).and_return(
            DfESignInUser.new(
              dfe_sign_in_uid: 123,
              email: placements_support_user.email,
              first_name: placements_support_user.first_name,
              last_name: placements_support_user.last_name,
              service: :placements,
            ),
          )
          expect(described_class.new.matches?(request)).to be(true)
        end
      end

      context "when the user is a claims support user" do
        it "returns true" do
          allow(HostingEnvironment).to receive(:current_service).and_return(:placements)
          allow(DfESignInUser).to receive(:load_from_session).and_return(
            DfESignInUser.new(
              dfe_sign_in_uid: 123,
              email: claims_support_user.email,
              first_name: claims_support_user.first_name,
              last_name: claims_support_user.last_name,
              service: :placements,
            ),
          )
          expect(described_class.new.matches?(request)).to be_nil
        end
      end

      context "when the user is a placements user" do
        it "returns true" do
          allow(HostingEnvironment).to receive(:current_service).and_return(:placements)
          allow(DfESignInUser).to receive(:load_from_session).and_return(
            DfESignInUser.new(
              dfe_sign_in_uid: 123,
              email: placements_user.email,
              first_name: placements_user.first_name,
              last_name: placements_user.last_name,
              service: :placements,
            ),
          )
          expect(described_class.new.matches?(request)).to be(false)
        end
      end

      context "when the user is a claims user" do
        it "returns true" do
          allow(HostingEnvironment).to receive(:current_service).and_return(:placements)
          allow(DfESignInUser).to receive(:load_from_session).and_return(
            DfESignInUser.new(
              dfe_sign_in_uid: 123,
              email: claims_user.email,
              first_name: claims_user.first_name,
              last_name: claims_user.last_name,
              service: :placements,
            ),
          )
          expect(described_class.new.matches?(request)).to be_nil
        end
      end
    end
  end
end
