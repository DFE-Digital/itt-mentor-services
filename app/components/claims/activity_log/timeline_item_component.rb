class Claims::ActivityLog::TimelineItemComponent < ApplicationComponent
  renders_many :attachments, "AttachmentComponent"

  def initialize(activity_log:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @activity_log = activity_log
  end

  def attachments
    case activity_log.activity
    when "payment_delivered"
      [activity_log.record.csv_file]
    end
  end

  private

  attr_reader :activity_log
end
