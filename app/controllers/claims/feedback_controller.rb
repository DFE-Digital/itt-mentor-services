class Claims::FeedbackController < Claims::ApplicationController
  skip_before_action :authenticate_user!
  before_action :skip_authorization
  before_action :set_feedback_form, only: %i[new create]

  def new; end

  def create
    if @feedback_form.valid?
      # Send params to zendesk... if we use it
      render :confirmation
    else
      render :new
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:option, :improve_comment, :email, :full_name) if params[:feedback]
  end

  def set_feedback_form
    @feedback_form = Claims::FeedbackForm.new(feedback_params)
  end
end
