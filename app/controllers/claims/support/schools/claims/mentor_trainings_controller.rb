class Claims::Support::Schools::Claims::MentorTrainingsController < Claims::ApplicationController
  include Claims::BelongsToSchool
  before_action :authorize_claim
  helper_method :mentor_training_form

  def edit
    if create_revision?
      @claim_revision = claim.create_revision!
    end
  end

  def update
    if mentor_training_form.save
      redirect_to mentor_training_form.success_path
    else
      render :edit
    end
  end

  private

  def mentor_training_form
    @mentor_training_form ||=
      if params[:claims_support_claim_mentor_training_form].present?
        Claims::Support::Claim::MentorTrainingForm.new(mentor_training_params)
      else
        Claims::Support::Claim::MentorTrainingForm.new(default_params)
      end
  end

  def mentor_training_params
    params.require(:claims_support_claim_mentor_training_form).permit(
      :hours_completed,
      :custom_hours_completed,
    ).merge(default_params)
  end

  def default_params
    { claim: @claim_revision || claim, mentor_training: }
  end

  def mentor_training
    current_claim = @claim_revision || claim
    mentor_training = current_claim.mentor_trainings.find_by_id(params.require(:id))

    @mentor_training ||= if mentor_training.nil?
                           current_claim.mentor_trainings.find_by(
                             mentor_id: current_claim.previous_revision.mentor_trainings.find(params.require(:id)).mentor_id,
                           )
                         else
                           mentor_training
                         end
  end

  def claim
    @claim ||= @school.claims.find(params.require(:claim_id))
  end

  def authorize_claim
    authorize claim
  end

  def create_revision?
    params[:revision] == "true"
  end
end
