require "rails_helper"

RSpec.describe HostingEnvironment do
  before do
    HostingEnvironment.instance_variable_set :@env, nil
    HostingEnvironment.instance_variable_set :@phase, nil
  end

  describe ".env" do
    subject(:env) { described_class.env }

    test_matrix = %w[production sandbox staging qa review development test]

    test_matrix.each do |environment|
      context "when HOSTING_ENV is '#{environment}'" do
        it "returns '#{environment}'" do
          ClimateControl.modify HOSTING_ENV: environment do
            expect(env).to eq(environment)
          end
        end
      end
    end
  end

  describe ".phase" do
    subject(:phase) { described_class.phase(current_service) }

    context "when environment is 'production'" do
      context "and service is 'claims'" do
        let(:current_service) { :claims }

        it "returns 'beta'" do
          ClimateControl.modify HOSTING_ENV: "production" do
            expect(phase).to eq("beta")
          end
        end
      end

      context "and service is 'placements'" do
        let(:current_service) { :placements }

        it "returns 'beta'" do
          ClimateControl.modify HOSTING_ENV: "production" do
            expect(phase).to eq("beta")
          end
        end
      end
    end

    context "when environment is not 'production'" do
      test_matrix = %w[sandbox staging qa review development test]

      test_matrix.each do |environment|
        context "when environment is '#{environment}'" do
          let(:current_service) { :claims }

          it "returns '#{environment}'" do
            ClimateControl.modify HOSTING_ENV: environment do
              expect(phase).to eq(environment)
            end
          end
        end
      end
    end
  end
end
