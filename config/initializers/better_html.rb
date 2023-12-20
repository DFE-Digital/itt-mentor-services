# better_html gem is only present in development and test
return if Rails.env.production?

BetterHtml.config =
  BetterHtml::Config.new(
    YAML.safe_load(File.read(Rails.root.join(".better-html.yml")))
  )

BetterHtml.configure do |config|
  config.template_exclusion_filter =
    proc { |filename| !filename.start_with?(Rails.root.to_s) }
end
