class SupportUserConstraint
  def matches?(request)
    service = HostingEnvironment.current_service(request)
    current_user = DfESignInUser.load_from_session(request.session, service:)&.user
    current_user&.support_user?
  end
end
