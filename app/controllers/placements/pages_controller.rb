class Placements::PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def start
    render locals: {
      content: File.read(Rails.root.join("app/views/placements/pages/landing-page.md")),
    }
  end

  def cookies
    render locals: {
      content: File.read(Rails.root.join("app/views/placements/pages/cookies.md")),
    }
  end
end
