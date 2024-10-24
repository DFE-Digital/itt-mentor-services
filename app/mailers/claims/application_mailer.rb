class Claims::ApplicationMailer < ApplicationMailer
  private

  def service_name
    I18n.t("claims.service_name")
  end

  def support_email
    I18n.t("claims.support_email")
  end

  def host
    ENV["CLAIMS_HOST"]
  end
end
