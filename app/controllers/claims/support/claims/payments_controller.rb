class Claims::Support::Claims::PaymentsController < Claims::Support::ApplicationController
  before_action :skip_authorization
end
