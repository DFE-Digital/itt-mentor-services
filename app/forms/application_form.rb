class ApplicationForm
  include ActiveModel::Model
  include ActionView::Helpers::TranslationHelper

  def initialize(attributes = {})
    @virtual_path = "forms/#{self.class.name.underscore}"

    super
  end
end
