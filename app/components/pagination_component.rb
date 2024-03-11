class PaginationComponent < ApplicationComponent
  attr_reader :pagy

  def initialize(pagy:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @pagy = pagy
  end

  def render?
    pagy.pages > 1
  end
end
