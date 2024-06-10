class DfESignInUser
  attr_reader :email, :dfe_sign_in_uid, :id_token, :provider, :service, :first_name, :last_name

  def initialize(email:, dfe_sign_in_uid:, first_name:, last_name:, service:, id_token: nil, provider: nil)
    @email = email&.downcase
    @dfe_sign_in_uid = dfe_sign_in_uid
    @first_name = first_name
    @last_name = last_name
    @id_token = id_token
    @provider = provider&.to_s
    @service = service
  end

  def self.begin_session!(session, omniauth_payload)
    session["dfe_sign_in_user"] = {
      "email" => omniauth_payload["info"]["email"],
      "dfe_sign_in_uid" => omniauth_payload["uid"],
      "first_name" => omniauth_payload["info"]["first_name"],
      "last_name" => omniauth_payload["info"]["last_name"],
      "last_active_at" => Time.current,
      "id_token" => omniauth_payload["credentials"]["id_token"],
      "provider" => omniauth_payload["provider"],
    }
  end

  def self.load_from_session(session, service:)
    dfe_sign_in_session = session["dfe_sign_in_user"]
    return unless dfe_sign_in_session

    # Users who signed in before session expiry was implemented will not have
    # `last_active_at` set. In that case, force them to sign in again.
    return unless dfe_sign_in_session["last_active_at"]

    return if dfe_sign_in_session.fetch("last_active_at") < 2.hours.ago

    dfe_sign_in_session["last_active_at"] = Time.current

    new(
      email: dfe_sign_in_session["email"],
      dfe_sign_in_uid: dfe_sign_in_session["dfe_sign_in_uid"],
      first_name: dfe_sign_in_session["first_name"],
      last_name: dfe_sign_in_session["last_name"],
      id_token: dfe_sign_in_session["id_token"],
      provider: dfe_sign_in_session["provider"],
      service:,
    )
  end

  def logout_url(request)
    if signed_in_from_dfe?
      dfe_logout_url(request)
    else
      "/auth/developer/sign-out"
    end
  end

  def user
    @user ||= support_user || non_support_user
  end

  def self.end_session!(session)
    session.clear
  end

  private

  def support_user
    @support_user ||= support_user_klass.find_by(dfe_sign_in_uid:) if dfe_sign_in_uid.present?
    return @support_user if @support_user.present?

    @support_user = support_user_klass.find_by(email:)
  end

  def non_support_user
    @non_support_user ||= user_klass.find_by(dfe_sign_in_uid:) if dfe_sign_in_uid.present?
    return @non_support_user if @non_support_user.present?

    @non_support_user = user_klass.find_by(email:)
  end

  def support_user_klass
    case service
    when :placements
      Placements::SupportUser
    when :claims
      Claims::SupportUser
    end
  end

  def user_klass
    case service
    when :placements
      Placements::User
    when :claims
      Claims::User
    end
  end

  def signed_in_from_dfe?
    @provider == "dfe"
  end

  def dfe_logout_url(request)
    uri = URI("#{ENV["DFE_SIGN_IN_ISSUER_URL"]}/session/end")
    uri.query = {
      id_token_hint: @id_token,
      post_logout_redirect_uri: "#{request.base_url}/auth/dfe/sign-out",
    }.to_query
    uri.to_s
  end
end
