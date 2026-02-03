class Claims::ClaimWindowDecorator < Draper::Decorator
  delegate_all

  def name
    "#{I18n.l(starts_on, format: :long)} to #{I18n.l(ends_on, format: :long)}"
  end

  def short_name
    "#{I18n.l(starts_on, format: :short)} to #{I18n.l(ends_on, format: :short)}"
  end
end
