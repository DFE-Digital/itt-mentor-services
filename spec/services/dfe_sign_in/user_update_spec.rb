require "rails_helper"

RSpec.describe DfESignIn::UserUpdate do
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

  subject { described_class.call(current_user:, sign_in_user:) }

  it "updates the user's sign in attributes" do
    expect { subject }.to change(current_user, :email).to("test@gmail.com")
      .and change(current_user, :first_name).to("John")
      .and change(current_user, :last_name).to("Doe")
      .and change(current_user, :dfe_sign_in_uid).to("123")
    expect(current_user.last_signed_in_at).to_not be_nil
  end
end
