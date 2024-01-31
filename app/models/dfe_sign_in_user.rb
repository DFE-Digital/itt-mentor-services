class DfESignInUser
  attr_reader :email, :dfe_sign_in_uid, :id_token, :provider
  attr_accessor :first_name, :last_name, :service

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

  def self.load_from_session(session)
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
      service: session["service"],
    )
  end

  def user
    @user ||= user_by_uid || user_by_email
  end

  def self.end_session!(session)
    session.clear
  end

  private

  def user_by_uid
    return if dfe_sign_in_uid.blank?

    support_user_klass.find_by(dfe_sign_in_uid:) ||
      user_klass.find_by(dfe_sign_in_uid:)
  end

  def user_by_email
    return if email.blank?

    support_user_klass.find_by(email:) ||
      user_klass.find_by(email:)
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
end
