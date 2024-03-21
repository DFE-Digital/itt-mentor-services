class Claims::ClaimDecorator < Draper::Decorator
  delegate_all

  def item_status_tag(association)
    if object.public_send(association).present?
      { text: I18n.t("decorators.claim.completed"), colour: "green" }
    else
      { text: I18n.t("decorators.claim.not_started"), colour: "grey" }
    end
  end
end
