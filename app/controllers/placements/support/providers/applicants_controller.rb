class Placements::Support::Providers::ApplicantsController < ApplicationController
  def index
    render locals: { applicants:, provider: }
  end

  def show
    render locals: { applicant:, provider:, nearby_schools: }
  end

  private

  def provider
    @provider ||= Provider.find(params.fetch(:provider_id))
  end

  def applicants
    @applicants ||= provider.applicants
  end

  def applicant
    @applicant ||= applicants.find(params.fetch(:id))
  end

  def nearby_schools
    @nearby_schools ||= School.near(applicant, 5)
  end
end
