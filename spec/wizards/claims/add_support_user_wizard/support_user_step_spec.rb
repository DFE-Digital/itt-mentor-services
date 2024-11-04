require "rails_helper"

RSpec.describe Claims::AddSupportUserWizard::SupportUserStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) { instance_double(Claims::AddSupportUserWizard) }
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(first_name: nil, last_name: nil, email: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value("name@education.gov.uk").for(:email) }
    it { is_expected.not_to allow_value("name@example.com").for(:email) }
    it { is_expected.not_to allow_value("some_text").for(:email) }

    describe "#new_support_user" do
      let(:first_name) { "John" }
      let(:last_name) { "Doe" }
      let(:email) { "john.doe@education.gov.uk" }
      let(:attributes) { { first_name:, last_name:, email: } }

      context "when the support user does not already exist" do
        it "returns valid" do
          expect(step.valid?).to be(true)
        end
      end

      context "when the support user already exists" do
        before { create(:claims_support_user, first_name:, last_name:, email:) }

        it "returns invalid" do
          expect(step.valid?).to be(false)
        end
      end

      context "when the support user is discarded" do
        before do
          create(:claims_support_user,
                 first_name:,
                 last_name:,
                 email:,
                 discarded_at: Time.current)
        end

        it "returns valid" do
          expect(step.valid?).to be(true)
        end
      end
    end

    describe "#support_user" do
      let(:first_name) { "John" }
      let(:last_name) { "Doe" }
      let(:email) { "john.doe@education.gov.uk" }
      let(:attributes) { { first_name:, last_name:, email: } }

      context "when the support user does not already exist" do
        it "returns a new record" do
          support_user = step.support_user
          expect(support_user.new_record?).to be(true)
          expect(support_user.first_name).to eq(first_name)
          expect(support_user.last_name).to eq(last_name)
          expect(support_user.email).to eq(email)
        end
      end

      context "when the support user already exists, and is discarded" do
        let!(:existing_support_user) do
          create(:claims_support_user,
                 first_name:,
                 last_name:,
                 email:,
                 discarded_at: Time.current)
        end

        it "returns the existing support user record" do
          support_user = step.support_user
          expect(support_user.new_record?).to be(false)
          expect(support_user).to eq(existing_support_user)
        end

        context "when the first name or last name do not match the record attributes" do
          let!(:existing_support_user) do
            create(:claims_support_user,
                   first_name: "Jake",
                   last_name: "Bloggs",
                   email:,
                   discarded_at: Time.current)
          end

          it "returns the existing support user record, with reassigned attributes" do
            support_user = step.support_user
            expect(support_user.new_record?).to be(false)
            expect(support_user.id).to eq(existing_support_user.id)
            expect(support_user.email).to eq(existing_support_user.email)
            expect(support_user.first_name).not_to eq(existing_support_user.first_name)
            expect(support_user.first_name).to eq(first_name)
            expect(support_user.last_name).not_to eq(existing_support_user.last_name)
            expect(support_user.last_name).to eq(last_name)
          end
        end
      end
    end
  end
end
