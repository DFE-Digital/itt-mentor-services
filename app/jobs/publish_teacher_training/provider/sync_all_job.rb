module PublishTeacherTraining
  module Provider
    class SyncAllJob < ApplicationJob
      queue_as :default

      def perform
        PublishTeacherTraining::Provider::Importer.call
      end
    end
  end
end
