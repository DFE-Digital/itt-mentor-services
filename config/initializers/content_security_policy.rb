# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Content security policy changed 30/06/2025 to align with GOOGLE API, to allow Google Maps integration:
# https://developers.google.com/maps/documentation/javascript/content-security-policy

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.font_src    :self, :https, :data, "https://fonts.gstatic.com"
    policy.img_src     :self, :https, :data, "https://*.googleapis.com", "https://*.gstatic.com", "*.google.com", "*.googleusercontent.com"
    policy.object_src  :none
    policy.script_src  :self, :https, "strict-dynamic", "unsafe-eval", :blob
    policy.style_src   :self, :https, "https://*.googleapis.com", :unsafe_inline
    policy.frame_src   "https://*.google.com"
    policy.connect_src :self, :data, :blob, "https://*.googleapis.com", "*.google.com", "https://*.gstatic.com"
    policy.worker_src  :blob

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
