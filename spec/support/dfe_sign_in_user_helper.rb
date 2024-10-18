module DfESignInUserHelper
  def sign_in_placements_user(organisations: [])
    @current_user = create(:placements_user)
    organisations.each do |organisation|
      create(:user_membership, user: @current_user, organisation:)
    end
    sign_in_as(@current_user)
  end
  alias_method :given_i_am_signed_in_as_a_placements_user, :sign_in_placements_user

  def sign_in_placements_support_user
    @current_user = create(:placements_support_user)
    sign_in_as(@current_user)
  end
  alias_method :given_i_am_signed_in_as_a_support_user, :sign_in_placements_support_user

  def sign_in_as(user)
    user_exists_in_dfe_sign_in(user:)

    case RSpec.current_example.metadata[:type]
    when :system
      visit sign_in_path
      click_on "Sign in using DfE Sign In"
    when :request
      get "/auth/dfe/callback"
      follow_redirect!
    end
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

  def when_dsi_fails
    OmniAuth.config.mock_auth[:dfe] = :invalid_credentials
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
