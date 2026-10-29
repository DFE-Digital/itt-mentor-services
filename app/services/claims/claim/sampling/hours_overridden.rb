class Claims::Claim::Sampling::HoursOverridden < ApplicationService
  def initialize(claim:, current_user:, provider_responses: [])
    @claim = claim
    @current_user = current_user
    @provider_responses = provider_responses
  end

  def call
    claim.transaction do
      update_mentor_trainings

      if clawback_hours?
        Claims::Claim::Clawback::MoveToClawback.call(claim:, current_user:)
      else
        Claims::AuditContext.set(actor: current_user) do
          Claims::Claim::Clawback::ClawbackNotRequired.call(claim:, esfa_responses:)
        end
      end
    end
  end

  private

  attr_reader :claim, :current_user, :provider_responses

  def update_mentor_trainings
    provider_responses.each do |provider_response|
      claim.mentor_trainings.find(provider_response[:id]).update!(
        not_assured: provider_response[:not_assured],
        reason_not_assured: provider_response[:reason_not_assured],
        hours_clawed_back: provider_response[:hours_clawed_back],
      )
    end
  end

  def clawback_hours?
    claim.mentor_trainings.reload.not_assured.sum { |mentor_training| mentor_training.hours_clawed_back.to_i }.positive?
  end

  def esfa_responses
    claim.mentor_trainings.not_assured.map { |mentor_training| { id: mentor_training.id } }
  end
end
