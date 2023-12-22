module ServicesTestHelper
  def given_i_am_on_the_claims_site
    Capybara.app_host = "http://#{ENV["CLAIMS_HOST"]}"
  end

  def given_i_am_on_the_placements_site
    Capybara.app_host = "http://#{ENV["PLACEMENTS_HOST"]}"
  end
end
