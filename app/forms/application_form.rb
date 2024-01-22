class ApplicationForm
  include ActiveModel::Model

  def translate(key, options = {})
    I18n.t(key, scope: key.starts_with?(".") ? i18n_scope : nil, **options)
  end
  alias_method :t, :translate

  private

  def i18n_scope
    "forms.#{self.class.name.underscore}"
  end
end
