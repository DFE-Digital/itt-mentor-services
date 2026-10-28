class Claims::Claim::ChangeProvider < ApplicationService
  AUDIT_STATUSES = %w[sampling_in_progress sampling_provider_not_approved].freeze

  def initialize(claim:, provider:)
    @claim = claim
    @provider = provider
  end

  def call
    ActiveRecord::Base.transaction do |transaction|
      requires_audit = AUDIT_STATUSES.include?(claim.status)

      claim.update!(provider:)
      claim.mentor_trainings.each { |mentor_training| move_mentor_training(mentor_training) }

      next unless requires_audit

      reset_audit
      provider_sampling = Claims::ProviderSampling.create!(provider:, claims: [claim], sampling:)

      transaction.after_commit do
        provider_sampling.provider_users.each do |provider_user|
          Claims::ProviderMailer.sampling_checks_required(provider_sampling, provider_user).deliver_later
        end
      end
    end
  end

  private

  attr_reader :claim, :provider

  def move_mentor_training(mentor_training)
    hours_completed = mentor_training.claimable_hours_with(provider)
    return mentor_training.destroy! if hours_completed.zero?

    mentor_training.provider = provider
    mentor_training.hours_completed = hours_completed
    mentor_training.set_training_type
    mentor_training.save!
  end

  def reset_audit
    claim.mentor_trainings.each do |mentor_training|
      mentor_training.update!(not_assured: false, reason_not_assured: nil, hours_clawed_back: nil)
    end
    claim.update!(status: :sampling_in_progress, amendment_notification_sent_at: nil)
  end

  def sampling
    claim.provider_samplings.order(:created_at).last&.sampling || Claims::Sampling.new
  end
end
