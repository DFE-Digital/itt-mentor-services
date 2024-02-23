module PublishTeacherTraining
  module Subject
    class SyncAllJob < ApplicationJob
      queue_as :default

      def perform
        PublishTeacherTraining::Subject::Import.call
      end
    end
  end
end
