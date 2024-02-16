class TRNMentorSyncJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    Mentor.find_each do |mentor|
      response = TeachingRecord::GetTeacher.call(trn: mentor.trn)
      mentor.update!(
        first_name: response["firstName"],
        last_name: response["lastName"],
      )
      response
    rescue TeachingRecord::RestClient::HttpError
      Rails.logger.error "TRNMentorSync was unable to update Mentor ID: #{mentor.id} TRN: #{mentor.trn}"
    end
  end
end
