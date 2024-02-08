class ApplicationForm
  include ActiveModel::Model
  include ActionView::Helpers::TranslationHelper

  def initialize(attributes = {})
    @virtual_path = "forms/#{self.class.name.underscore}"

    super
  end

  # Defaults to doing nothing and signaling a successful save.
  # Override this method in your subclass to implement your own persistence logic.
  # Side effects like sending notifications should not be triggered from this method.
  def persist
    true
  end

  def save
    validate ? persist : false
  end

  def save!
    validate ? persist : raise_validation_error
  end

  private

  def raise_validation_error
    raise ActiveModel::ValidationError, self
  end
end
