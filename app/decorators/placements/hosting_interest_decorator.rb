class Placements::HostingInterestDecorator < Draper::Decorator
  delegate_all

  def status
    case appetite
    when "not_open"
      I18n.t("#{translation_path}.not_open")
    when "interested"
      I18n.t("#{translation_path}.interested")
    else
      I18n.t("#{translation_path}.actively_looking")
    end
  end

  private

  def translation_path
    "activerecord.attributes.placements/hosting_interest.appetite"
  end
end
