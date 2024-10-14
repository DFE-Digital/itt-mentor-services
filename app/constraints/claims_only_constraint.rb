class ClaimsOnlyConstraint
  def matches?(request)
    HostingEnvironment.current_service(request) == :claims
  end
end
