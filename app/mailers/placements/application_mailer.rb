class Placements::ApplicationMailer < ApplicationMailer
  private

  def service_name
    I18n.t("placements.service_name")
  end

  def support_email
    I18n.t("placements.support_email")
  end

  def host
    ENV["PLACEMENTS_HOST"]
  end
end
