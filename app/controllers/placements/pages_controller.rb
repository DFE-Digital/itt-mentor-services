class Placements::PagesController < ApplicationController
  skip_before_action :authenticate_user!

  def start
    render locals: {
      content: File.read(Rails.root.join("app/views/placements/pages/landing-page.md")),
    }
  end

  def show
    page = params[:page]
    render locals: {
      page:,
      content: File.read(Rails.root.join("app/views/placements/pages/#{page}.md")),
    }
  end
end
