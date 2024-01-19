class UserDecorator < Draper::Decorator
  delegate_all

  FORM_PARAMS = %i[first_name last_name email].freeze

  def as_form_params
    { "#{service}_user" => slice(FORM_PARAMS) }
  end
end
