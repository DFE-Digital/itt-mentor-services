# frozen_string_literal: true

class NavigationBar < ApplicationComponent
  attr_reader :items, :current_path

  def initialize(
    items:,
    current_path:,
    current_user: {},
    classes: [],
    html_attributes: {}
  )
    super(classes:, html_attributes:)
    @items = items
    @current_path = current_path
    @current_user = current_user
  end
end
