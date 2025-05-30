class DfESignInUser
  # Sessions timeout after this period of inactivity
  SESSION_TIMEOUT = 2.hours

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
      "email" => omniauth_payload.dig("info", "email"),
      "dfe_sign_in_uid" => omniauth_payload["uid"],
      "first_name" => omniauth_payload.dig("info", "first_name"),
      "last_name" => omniauth_payload.dig("info", "last_name"),
      "last_active_at" => Time.current,
      "id_token" => omniauth_payload.dig("credentials", "id_token"),
      "provider" => omniauth_payload["provider"],
    }
  end

  def self.load_from_session(session, service:)
    dfe_sign_in_session = session["dfe_sign_in_user"]
    return unless dfe_sign_in_session

    # Users who signed in before session expiry was implemented will not have
    # `last_active_at` set. In that case, force them to sign in again.
    return unless dfe_sign_in_session["last_active_at"]

    return if dfe_sign_in_session.fetch("last_active_at") < SESSION_TIMEOUT.ago

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
    @user ||= User.where(type: [support_user_klass, user_klass].map(&:to_s))
      .and(
        User.where(dfe_sign_in_uid:).where.not(dfe_sign_in_uid: nil)
          .or(User.where(email:)),
      )
      .order(type: :asc) # so support users take precedence
      .first
  end

  def self.end_session!(session)
    session.clear
  end

  private

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
