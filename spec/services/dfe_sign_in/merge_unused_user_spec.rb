require "rails_helper"

# When a person is re-added under a new email, the new record is never signed
# into: they keep signing in with their existing DfE Sign In account, which
# resolves to their original record. This hands the unused record's
# memberships to the record they actually sign in as.
RSpec.describe DfESignIn::MergeUnusedUser do
  subject(:merge) { described_class.call(current_user:, sign_in_user:) }

  # Schools first: the claims_school factory records grant conditions as
  # accepted by User.first, which would otherwise tie the school to a user here.
  let!(:shelbyville_school) { create(:claims_school, name: "Shelbyville Elementary") }
  let!(:springfield_school) { create(:claims_school, name: "Springfield Elementary") }
  let!(:current_user) { create(:claims_user, email: "anne.old@example.com", dfe_sign_in_uid: "anne-uid") }
  let(:sign_in_user) do
    instance_double(DfESignInUser, email: "anne.new@example.com", dfe_sign_in_uid: "anne-uid")
  end

  it_behaves_like "a service object" do
    let(:params) { { current_user:, sign_in_user: } }
  end

  context "when an unused record of the same type has the DfE Sign In email" do
    let!(:unused_user) do
      create(:claims_user, email: "anne.new@example.com", dfe_sign_in_uid: nil, last_signed_in_at: nil)
    end

    before do
      create(:user_membership, user: unused_user, organisation: shelbyville_school)
      create(:user_membership, user: unused_user, organisation: springfield_school)
    end

    it "moves the unused record's memberships to the current user" do
      merge

      expect(current_user.reload.schools).to contain_exactly(shelbyville_school, springfield_school)
    end

    it "deletes the unused record" do
      merge

      expect(User.unscoped.exists?(unused_user.id)).to be(false)
    end

    it "frees the email for the current user" do
      merge

      expect(Claims::User.unscoped.where(email: "anne.new@example.com")).to be_empty
    end

    context "when the current user is already a member of one of the organisations" do
      before { create(:user_membership, user: current_user, organisation: shelbyville_school) }

      it "keeps a single membership for each organisation" do
        merge

        expect(current_user.reload.user_memberships.pluck(:organisation_id))
          .to contain_exactly(shelbyville_school.id, springfield_school.id)
      end
    end

    context "when the unused record is referenced by other records" do
      before do
        create(:grant_conditions_acceptance, accepted_by: unused_user)
        allow(Sentry).to receive(:capture_message)
      end

      it "leaves both records as they were" do
        merge

        expect(unused_user.reload.schools).to contain_exactly(shelbyville_school, springfield_school)
        expect(current_user.reload.schools).to be_empty
      end

      it "reports it to Sentry" do
        merge

        expect(Sentry).to have_received(:capture_message).with(
          "Could not merge unused user into signed in user",
          extra: { user_id: current_user.id, unused_user_id: unused_user.id },
        )
      end
    end
  end

  context "when the record with the DfE Sign In email has a DfE Sign In uid" do
    let!(:other_user) { create(:claims_user, email: "anne.new@example.com", dfe_sign_in_uid: "someone-else") }

    before { create(:user_membership, user: other_user, organisation: shelbyville_school) }

    it "leaves it alone" do
      merge

      expect(other_user.reload.schools).to contain_exactly(shelbyville_school)
      expect(current_user.reload.schools).to be_empty
    end
  end

  context "when the record with the DfE Sign In email has been signed into" do
    let!(:other_user) do
      create(:claims_user, email: "anne.new@example.com", dfe_sign_in_uid: nil, last_signed_in_at: 1.day.ago)
    end

    before { create(:user_membership, user: other_user, organisation: shelbyville_school) }

    it "leaves it alone" do
      merge

      expect(other_user.reload.schools).to contain_exactly(shelbyville_school)
      expect(current_user.reload.schools).to be_empty
    end
  end

  context "when the record with the DfE Sign In email is a different type of user" do
    let!(:provider_user) do
      create(:claims_provider_user, email: "anne.new@example.com", dfe_sign_in_uid: nil, last_signed_in_at: nil)
    end

    it "leaves it alone" do
      expect { merge }.not_to change(User, :count)
      expect(provider_user.reload).to be_present
    end
  end

  context "when the current user already has the DfE Sign In email" do
    let(:current_user) { create(:claims_user, email: "anne.new@example.com", dfe_sign_in_uid: "anne-uid") }

    it "does nothing" do
      expect { merge }.not_to change(User, :count)
    end
  end

  context "when the current user is a placements user" do
    let(:current_user) { create(:placements_user, email: "anne.old@example.com", dfe_sign_in_uid: "anne-uid") }
    let(:placements_school) { create(:placements_school, name: "Shelbyville Elementary") }
    let!(:unused_user) do
      create(:placements_user, email: "anne.new@example.com", dfe_sign_in_uid: nil, last_signed_in_at: nil)
    end

    before { create(:user_membership, user: unused_user, organisation: placements_school) }

    it "moves the unused record's memberships to the current user" do
      merge

      expect(current_user.reload.schools).to contain_exactly(placements_school)
      expect(User.unscoped.exists?(unused_user.id)).to be(false)
    end
  end

  context "when the current user is a support user" do
    let(:current_user) { create(:claims_support_user, email: "colin.old@education.gov.uk", dfe_sign_in_uid: "colin-uid") }
    let(:sign_in_user) do
      instance_double(DfESignInUser, email: "colin.new@education.gov.uk", dfe_sign_in_uid: "colin-uid")
    end

    before { create(:claims_support_user, email: "colin.new@education.gov.uk", dfe_sign_in_uid: nil, last_signed_in_at: nil) }

    it "does nothing" do
      expect { merge }.not_to change(User, :count)
    end
  end
end
