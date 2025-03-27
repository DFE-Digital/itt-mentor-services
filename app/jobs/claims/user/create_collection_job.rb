class Claims::User::CreateCollectionJob < ApplicationJob
  queue_as :default

  MAX_COUNT = 500

  def perform(user_details:)
    if user_details.count > MAX_COUNT
      user_details.each_slice(MAX_COUNT) do |batch|
        Claims::User::CreateCollectionJob.perform_later(user_details: batch)
      end
    else
      user_details.each do |user_detail|
        school = Claims::School.find(user_detail[:school_id])
        existing_user = school.users.find_by(email: user_detail[:email])
        next if existing_user.present?

        Claims::User::CreateAndDeliverJob.perform_later(school_id: school.id, user_details: user_detail)
      end
    end
  end
end
