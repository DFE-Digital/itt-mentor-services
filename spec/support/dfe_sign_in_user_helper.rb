module DfESignInUserHelper
  def sign_in_as(user)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end
  alias_method :given_i_sign_in_as, :sign_in_as

  def user_exists_in_dfe_sign_in(user:)
    OmniAuth.config.mock_auth[:dfe] = OmniAuth::AuthHash.new(
      fake_dfe_sign_in_auth_hash(
        email: user.email,
        dfe_sign_in_uid: user.dfe_sign_in_uid,
        first_name: user.first_name,
        last_name: user.last_name,
      ),
    )
  end

  def invalid_dfe_sign_in_response
    {
      "provider" => "dfe",
      "uid" => nil,
    }
  end

  private

  def fake_dfe_sign_in_auth_hash(email:, dfe_sign_in_uid:, first_name:, last_name:)
    {
      "provider" => "dfe",
      "uid" => dfe_sign_in_uid,
      "info" => {
        "name" => "#{first_name} #{last_name}",
        "email" => email,
        "nickname" => nil,
        "first_name" => first_name,
        "last_name" => last_name,
        "gender" => nil,
        "image" => nil,
        "phone" => nil,
        "urls" => { "website" => nil },
      },
      "credentials" => {
        "id_token" => "id_token",
        "token" => "DFE_SIGN_IN_TOKEN",
        "refresh_token" => nil,
        "expires_in" => 3600,
        "scope" => "email openid",
      },
      "extra" => {
        "raw_info" => {
          "email" => email,
          "sub" => dfe_sign_in_uid,
        },
      },
    }
  end
end
