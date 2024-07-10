# frozen_string_literal: true

class InlineCodeComponent < ApplicationComponent
  def initialize(snippet)
    @snippet = snippet
  end
end
