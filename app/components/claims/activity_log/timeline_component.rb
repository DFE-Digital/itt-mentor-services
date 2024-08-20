class Claims::ActivityLog::TimelineComponent < ApplicationComponent
  renders_many :items, Claims::ActivityLog::TimelineItemComponent
end
