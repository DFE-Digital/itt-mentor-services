module TeachingRecord
  class SyncMentorJob < ApplicationJob
    queue_as :default

    def perform(mentor)
      response = TeachingRecord::GetTeacher.call(trn: mentor.trn)
      mentor.update!(
        first_name: response["firstName"],
        last_name: response["lastName"],
      )
    rescue TeachingRecord::RestClient::TeacherNotFoundError => e
      Sentry.capture_exception(e)
    end
  end
end
