FactoryBot::SyntaxRunner.class_eval do
  include RSpec::Rails::FileFixtureSupport
end

RSpec.configure { |config| config.include FactoryBot::Syntax::Methods }
