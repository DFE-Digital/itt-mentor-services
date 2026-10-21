class Claims::SchoolsController < Claims::ApplicationController
  before_action :redirect_to_school_claims_when_belongs_to_one_school, only: :index
  before_action :authorize_school
  before_action :set_school, only: :show
  before_action :has_school_accepted_grant_conditions?, only: :show

  def index
    @schools = policy_scope(Claims::School.order_by_name)
    @providers = provider_memberships
  end

  def show; end

  private

  def set_school
    @school = policy_scope(Claims::School).find(params.require(:id)).decorate
    session[:claims_current_school_id] = @school.id
  end

  def redirect_to_school_claims_when_belongs_to_one_school
    if policy_scope(Claims::School).one? && provider_memberships.none?
      redirect_to claims_school_claims_path(current_user.schools.first)
    end
  end

  # Providers the user is a member of, when they also have a provider user record.
  def provider_memberships
    return Claims::Provider.none if current_user.support_user?

    @provider_memberships ||= claims_provider_choices.order_by_name
  end

  def authorize_school
    authorize @school || Claims::School
  end
end
