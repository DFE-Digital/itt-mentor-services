class Claims::PagesController < Claims::ApplicationController
  skip_before_action :authenticate_user!

  before_action :skip_authorization

  before_action :redirect_to_after_sign_in_path, only: :start, if: :user_signed_in?

  def start; end
end
