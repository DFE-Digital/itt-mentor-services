module WizardController
  extend ActiveSupport::Concern

  included do
    helper_method :current_step_path, :back_link_path

    def new
      redirect_to step_path(@wizard.first_step)
    end

    def edit; end

    private

    def state_key
      @state_key ||= params.fetch(:state_key, BaseWizard.generate_state_key)
    end

    def current_step_path
      step_path(@wizard.current_step)
    end

    def back_link_path
      if @wizard.previous_step.present?
        step_path(@wizard.previous_step)
      else
        index_path
      end
    end
  end
end
