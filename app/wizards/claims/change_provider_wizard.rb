module Claims
  class ChangeProviderWizard < BaseWizard
    attr_reader :claim, :success_message

    def initialize(claim:, params:, state:, current_step: nil)
      @claim = claim
      super(state:, params:, current_step:)
    end

    delegate :academic_year, :reference, to: :claim
    delegate :name, to: :provider, prefix: true, allow_nil: true

    def define_steps
      add_step(ProviderStep)
      add_step(ProviderOptionsStep) if steps.fetch(:provider).provider.blank?
      add_step(CheckYourAnswersStep)
    end

    def provider
      steps[:provider_options]&.provider || steps.fetch(:provider).provider
    end

    def requires_audit?
      Claims::Claim::ChangeProvider::AUDIT_STATUSES.include?(claim.status)
    end

    def claimable_hours_for(provider)
      claim.mentor_trainings.index_with { |mentor_training| mentor_training.claimable_hours_with(provider) }
    end

    def removed_mentor_trainings
      claimable_hours_for(provider).select { |_mentor_training, hours| hours.zero? }.keys
    end

    def reduced_mentor_trainings
      claimable_hours_for(provider).select do |mentor_training, hours|
        hours.positive? && hours < mentor_training.hours_completed
      end
    end

    def change_provider
      raise "Invalid wizard state" unless valid?

      @success_message = build_success_message
      Claims::Claim::ChangeProvider.call(claim:, provider:)
    end

    private

    def build_success_message
      scope = "wizards.claims.change_provider_wizard.success"
      messages = []
      messages << I18n.t("#{scope}.audit_requested", provider_name:) if requires_audit?
      removed_mentor_trainings.each do |mentor_training|
        messages << I18n.t("#{scope}.mentor_removed", mentor_name: mentor_training.mentor_full_name)
      end
      reduced_mentor_trainings.each do |mentor_training, hours|
        messages << I18n.t("#{scope}.hours_reduced", mentor_name: mentor_training.mentor_full_name, hours:)
      end
      messages.join(" ").presence
    end
  end
end
