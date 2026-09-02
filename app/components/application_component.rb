class ApplicationComponent < GovukComponent::Base
  include GovukLinkHelper
  include GovukVisuallyHiddenHelper
  include GovukComponentsHelper

  include MoneyRails::ActionViewExtension

  def initialize(classes: [], html_attributes: {})
    super(classes:, html_attributes:)
  end

  def virtual_path
    "components/#{self.class.name.underscore}"
  end

  private

  def default_attributes
    {}
  end
end
