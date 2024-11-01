require "rails_helper"

RSpec.describe Claims::AddUserWizard::UserStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::AddUserWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:organisation).and_return(organisation)
    end
  end
  let(:organisation) { create(:claims_school) }
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(first_name: nil, last_name: nil, email: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value("name@education.gov.uk").for(:email) }
    it { is_expected.to allow_value("name@example.com").for(:email) }
    it { is_expected.not_to allow_value("some_text").for(:email) }

    describe "#new_membership" do
      let(:first_name) { "John" }
      let(:last_name) { "Doe" }
      let(:email) { "joe_doe@example.com" }
      let(:attributes) { { first_name:, last_name:, email: } }

      context "when the user is not already associated with the organisation" do
        it "returns valid" do
          expect(step.valid?).to be(true)
        end
      end

      context "when the user is already associated with the organisation" do
        let(:user) { create(:claims_user, first_name:, last_name:, email:) }
        let(:membership) { create(:user_membership, user:, organisation:) }

        before do
          membership
        end

        it "returns invalid" do
          expect(step.valid?).to be(false)
        end
      end
    end

    describe "#user" do
      let(:first_name) { "John" }
      let(:last_name) { "Doe" }
      let(:email) { "joe_doe@example.com" }
      let(:attributes) { { first_name:, last_name:, email: } }

      context "when the user does not already exist" do
        it "returns a new record" do
          user = step.user
          expect(user.new_record?).to be(true)
          expect(user.first_name).to eq(first_name)
          expect(user.last_name).to eq(last_name)
          expect(user.email).to eq(email)
        end
      end

      context "when the user already exists" do
        let!(:existing_user) { create(:claims_user, first_name:, last_name:, email:) }

        it "returns the existing user record" do
          user = step.user
          expect(user.new_record?).to be(false)
          expect(user).to eq(existing_user)
        end
      end

      context "when the first name or last name do not match the user record attributes" do
        let!(:existing_user) { create(:claims_user, first_name: "Jake", last_name: "Bloggs", email:) }

        it "returns the existing user record, with reassigned attributes" do
          user = step.user
          expect(user.new_record?).to be(false)
          expect(user.id).to eq(existing_user.id)
          expect(user.email).to eq(existing_user.email)
          expect(user.first_name).not_to eq(existing_user.first_name)
          expect(user.first_name).to eq(first_name)
          expect(user.last_name).not_to eq(existing_user.last_name)
          expect(user.last_name).to eq(last_name)
        end
      end
    end

    describe "#membership" do
      let(:first_name) { "John" }
      let(:last_name) { "Doe" }
      let(:email) { "joe_doe@example.com" }
      let(:attributes) { { first_name:, last_name:, email: } }
      let!(:user) { create(:claims_user, first_name:, last_name:, email:) }

      it "returns a new membership between the user and the organisation" do
        membership = step.membership
        expect(membership.new_record?).to be(true)
        expect(membership.user).to eq(user)
        expect(membership.organisation).to eq(organisation)
      end
    end
  end
end
