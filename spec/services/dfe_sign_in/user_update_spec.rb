require "rails_helper"

RSpec.describe DfESignIn::UserUpdate do
  subject(:dfe_sign_in) { described_class.call(current_user:, sign_in_user:) }

  let(:current_user) { create(:claims_user) }
  let(:sign_in_user) do
    instance_double(
      DfESignInUser,
      email: "test@gmail.com",
      first_name: "John",
      last_name: "Doe",
      dfe_sign_in_uid: 123,
    )
  end

  it_behaves_like "a service object" do
    let(:params) { { current_user:, sign_in_user: } }
  end

  it "updates the user's sign in attributes" do
    expect { dfe_sign_in }.to change(current_user, :email).to("test@gmail.com")
      .and change(current_user, :first_name).to("John")
      .and change(current_user, :last_name).to("Doe")
      .and change(current_user, :dfe_sign_in_uid).to("123")
    expect(current_user.last_signed_in_at).not_to be_nil
  end

  context "when another user of the same type already has the DfE Sign In email" do
    let(:current_user) { create(:claims_user, email: "anne.old@example.com") }
    let!(:other_user) { create(:claims_user, email: "test@gmail.com", dfe_sign_in_uid: "someone-else") }

    before { allow(Sentry).to receive(:capture_message) }

    it "records the sign in and keeps the user's existing email" do
      Timecop.freeze(Time.current.change(usec: 0)) do
        dfe_sign_in

        current_user.reload
        expect(current_user.email).to eq("anne.old@example.com")
        expect(current_user.dfe_sign_in_uid).to eq("123")
        expect(current_user.first_name).to eq("John")
        expect(current_user.last_signed_in_at).to eq(Time.current)
      end
    end

    it "reports the email clash to Sentry with both user ids" do
      dfe_sign_in

      expect(Sentry).to have_received(:capture_message).with(
        a_string_including("DfE Sign In email already belongs to another user"),
        hash_including(extra: { user_id: current_user.id, other_user_id: other_user.id }),
      )
    end

    it "is successful" do
      expect(dfe_sign_in).to be_successful
    end
  end

  context "when a user of a different type has the DfE Sign In email" do
    before { create(:claims_provider_user, email: "test@gmail.com") }

    it "updates the email as normal" do
      expect { dfe_sign_in }.to change(current_user, :email).to("test@gmail.com")
    end
  end
end
