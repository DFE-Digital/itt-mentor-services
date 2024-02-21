module TeachingRecord
  class SyncAllMentorsJob < ApplicationJob
    queue_as :default

    def perform
      # ISSUE 1: Teaching Record Service only has an API to handle requests per TRN.
      # ISSUE 2: Teaching Record Service request limit is 300 requests per minute.

      # Find mentors in batches of 300.
      Mentor.find_in_batches(batch_size: 300).with_index do |mentors, batch_index|
        mentors.each do |mentor|
          # Each batch of 300 mentors is processed 1 minute apart.
          TeachingRecord::SyncMentorJob.set(wait: batch_index.minutes).perform_later(mentor)
        end
      end
    end
  end
end
