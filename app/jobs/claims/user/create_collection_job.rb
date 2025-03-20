class Claims::User::CreateCollectionJob < ApplicationJob
  queue_as :default

  def perform(school_id:, user_details:)
    school = Claims::School.find(school_id)

    user_details.each do |user_detail|
      existing_user = school.users.find_by(email: user_detail[:email])
      next if existing_user.present?

      Claims::User::CreateAndDeliverJob.perform_later(school_id:, user_details: user_detail)
    end
  end
end
