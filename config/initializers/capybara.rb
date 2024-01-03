# https://github.com/teamcapybara/capybara/issues/2705#issuecomment-1752093026

if Rails.env.test?
  require "rackup"

  module Rack
    Handler = ::Rackup::Handler
  end
end
