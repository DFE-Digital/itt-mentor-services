class DfESignInUser
  attr_reader :email, :dfe_sign_in_uid
  attr_accessor :first_name, :last_name, :service

  # setup inspired by register-trainee-teacher
  # TODO: Replace with commented code when DfE Sign In implemented

  # def initialize(email:, dfe_sign_in_uid:, first_name:, last_name:, id_token: nil, provider: "dfe", service:)
  def initialize(email:, first_name:, last_name:, service:)
    @email = email&.downcase
    # @dfe_sign_in_uid = dfe_sign_in_uid
    @first_name = first_name
    @last_name = last_name
    # @id_token = id_token
    # @provider = provider&.to_s
    @service = service
  end

  def self.begin_session!(session, omniauth_payload)
    session["dfe_sign_in_user"] = {
      "email" => omniauth_payload["info"]["email"],
      # "dfe_sign_in_uid" => omniauth_payload["uid"],
      "first_name" => omniauth_payload["info"]["first_name"],
      "last_name" => omniauth_payload["info"]["last_name"],
      # "last_active_at" => Time.zone.now,
      # "id_token" => omniauth_payload["credentials"]["id_token"],
      # "provider" => omniauth_payload["provider"],
    }
  end

  def self.load_from_session(session)
    dfe_sign_in_session = session["dfe_sign_in_user"]
    return unless dfe_sign_in_session

    new(
      email: dfe_sign_in_session["email"],
      # dfe_sign_in_uid: dfe_sign_in_session["dfe_sign_in_uid"],
      first_name: dfe_sign_in_session["first_name"],
      last_name: dfe_sign_in_session["last_name"],
      # id_token: dfe_sign_in_session["id_token"],
      # provider: dfe_sign_in_session["provider"],
      service: session["service"],
    )
  end

  def user
    # TODO: When dfe sign-in is fully implemented, we will be able to find the user by the id == id_token.
    @user ||= User.find_by(email:)
  end

  def self.end_session!(session)
    session.clear
  end
end
