class Claims::User::CreateCollectionJob < ApplicationJob
  queue_as :default

  MAX_COUNT = 500
  MAX_CREATE_AND_DELIVER_PER_MINUTE = 100

  def perform(user_details:)
    if user_details.count > MAX_COUNT
      user_details.each_slice(MAX_COUNT) do |batch|
        Claims::User::CreateCollectionJob.perform_later(user_details: batch)
      end
    else
      user_details.each_with_index do |user_detail, index|
        school = Claims::School.find(user_detail[:school_id])
        existing_user = school.users.find_by(email: user_detail[:email])
        next if existing_user.present?

        wait_time = (index / MAX_CREATE_AND_DELIVER_PER_MINUTE).minutes

        Claims::User::CreateAndDeliverJob.set(wait: wait_time).perform_later(
          school_id: school.id,
          user_details: user_detail,
        )
      end
    end
  end
end
