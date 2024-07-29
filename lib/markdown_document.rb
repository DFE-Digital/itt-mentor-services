class MarkdownDocument
  YAML_FRONT_MATTER_REGEXP = /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m

  attr_reader :raw_content

  def initialize(raw_content)
    @raw_content = raw_content
  end

  def front_matter
    @front_matter ||= YAML.safe_load(@raw_content.match(YAML_FRONT_MATTER_REGEXP).to_s, permitted_classes: [Date])
  end

  delegate :[], to: :front_matter

  def content
    @content ||= @raw_content.gsub(YAML_FRONT_MATTER_REGEXP, "")
  end

  alias_method :to_s, :content

  def ==(other)
    raw_content == other.raw_content
  end

  def self.from_file(file)
    new(File.read(file))
  end

  def self.from_directory(directory)
    Dir.glob(Rails.root.join(directory, "*.md")).map do |file|
      from_file(file)
    end
  end
end
