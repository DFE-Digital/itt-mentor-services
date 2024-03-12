require "rails_helper"

RSpec.describe "Error pages", type: :system do
  describe "Claims errors", service: :claims do
    it "shows the 404 error page" do
      when_i_visit("/404")
      then_i_see_404_content_for("Claim funding for mentor training")
    end

    it "shows the 422 error page" do
      when_i_visit("/422")
      then_i_see_422_content_for("Claim funding for mentor training")
    end

    it "shows the 500 error page" do
      when_i_visit("/500")
      then_i_see_500_content
    end

    it "shows the 429 error page " do
      when_i_visit("/429")
      then_i_see_429_content
    end
  end

  describe "Placements errors", service: :placements do
    it "shows the 404 error page" do
      when_i_visit("/404")
      then_i_see_404_content_for("Manage school placements")
    end

    it "shows the 422 error page" do
      when_i_visit("/422")
      then_i_see_422_content_for("Manage school placements")
    end

    it "shows the 500 error page" do
      when_i_visit("/500")
      then_i_see_500_content
    end

    it "shows the 429 error page " do
      when_i_visit("/429")
      then_i_see_429_content
    end
  end

  private

  def when_i_visit(path)
    visit path
  end

  def then_i_see_404_content_for(service_name)
    expect(page).to have_title "Page not found"
    expect(page).to have_content "Page not found"
    expect(page).to have_content "If you entered a web address, check it is correct."
    expect(page).to have_content "If you pasted the web address, check you copied the entire address."
    expect(page).to have_content "If the web address is correct or you selected a link or button and you need to speak to someone about this problem, contact the #{service_name} team: becomingateacher@digital.education.gov.uk"
    expect(page.driver.status_code).to eq 404
  end

  def then_i_see_422_content_for(service_name)
    expect(page).to have_title "Sorry, there’s a problem with the service"
    expect(page).to have_content "Sorry, there’s a problem with the service"
    expect(page).to have_content "Try again later."
    expect(page).to have_content "If you continue to see this error contact the #{service_name} team: becomingateacher@digital.education.gov.uk"
    expect(page.driver.status_code).to eq 422
  end

  def then_i_see_500_content
    expect(page).to have_title "Sorry, there’s a problem with the service"
    expect(page).to have_content "Sorry, there’s a problem with the service"
    expect(page).to have_content "Try again later."
    expect(page).to have_content "If you reached this page after submitting information then it has not been saved. You’ll need to enter it again when the service is available."
    expect(page.driver.status_code).to eq 500
  end

  def then_i_see_429_content
    expect(page).to have_title "Sorry, there’s a problem with the service"
    expect(page).to have_content "Sorry, there’s a problem with the service"
    expect(page).to have_content "Try again later."
    expect(page).to have_content "If you have any questions, please email us at becomingateacher@digital.education.gov.uk"
    expect(page.driver.status_code).to eq 429
  end
end
