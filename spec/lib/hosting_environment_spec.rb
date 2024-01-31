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

  describe ".dfe_sign_in_client_id" do
    it "returns the dfe sign in client id for claims" do
      current_service = "claims"
      expect(described_class.dfe_sign_in_client_id(current_service)).to eq("123")
    end

    it "returns the dfe sign in client id for placements" do
      current_service = "placements"
      expect(described_class.dfe_sign_in_client_id(current_service)).to eq("123")
    end
  end

  describe ".dfe_sign_in_secret" do
    it "returns the dfe sign in secret for claims" do
      current_service = "claims"
      expect(described_class.dfe_sign_in_secret(current_service)).to eq("secret")
    end

    it "returns the dfe sign in secret for placements" do
      current_service = "placements"
      expect(described_class.dfe_sign_in_secret(current_service)).to eq("secret")
    end
  end

  describe ".application_url" do
    it "returns the application url for claims" do
      current_service = "claims"
      expect(described_class.application_url(current_service)).to eq(
        "https://claims.localhost",
      )
    end

    it "returns the application url for placements" do
      current_service = "placements"
      expect(described_class.application_url(current_service)).to eq(
        "https://placements.localhost",
      )
    end

    context "when env is development" do
      it "returns the application url for claims with port" do
        allow(Rails.env).to receive(:development?).and_return(true)
        current_service = "claims"

        expect(described_class.application_url(current_service)).to eq(
          "http://claims.localhost:3000",
        )
      end

      it "returns the application url for placements with port" do
        allow(Rails.env).to receive(:development?).and_return(true)
        current_service = "placements"

        expect(described_class.application_url(current_service)).to eq(
          "http://placements.localhost:3000",
        )
      end
    end
  end

  describe ".current_service" do
    it "returns the current service for claims" do
      request = double(host: ENV["CLAIMS_HOST"])
      expect(described_class.current_service(request)).to eq(:claims)
    end

    it "returns the current service for placements" do
      request = double(host: ENV["PLACEMENTS_HOST"])
      expect(described_class.current_service(request)).to eq(:placements)
    end
  end
end
