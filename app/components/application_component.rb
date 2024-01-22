class ApplicationComponent < GovukComponent::Base
  def initialize(classes: [], html_attributes: {})
    @virtual_path = "components/#{self.class.name.underscore}"

    super(classes:, html_attributes:)
  end

  private

  def default_attributes
    {}
  end
end
