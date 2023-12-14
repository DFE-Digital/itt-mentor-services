class ServiceUpdate
  CLAIMS_SERVICE_UPDATES_YAML_FILE =
    Rails.root.join("db/claims_service_updates.yml").freeze
  PLACEMENTS_SERVICE_UPDATES_YAML_FILE =
    Rails.root.join("db/placements_service_updates.yml").freeze

  attr_accessor :date, :title, :content

  def initialize(title:, date:, content:)
    @title = title
    @date = date
    @content = content
  end

  def id
    title.parameterize
  end

  def self.where(service:)
    path = file_path(service:)
    updates = YAML.load_file(path, symbolize_names: true) || []

    updates.map { |service_update| new(**service_update) }
  end

  def self.file_path(service:)
    case service
    when :claims
      CLAIMS_SERVICE_UPDATES_YAML_FILE
    when :placements
      PLACEMENTS_SERVICE_UPDATES_YAML_FILE
    end
  end
end
