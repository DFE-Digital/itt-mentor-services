class ContentHeaderComponent < ApplicationComponent
  attr_reader :title, :actions

  def initialize(title:, actions:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @title = title
    @actions = actions
  end
end
