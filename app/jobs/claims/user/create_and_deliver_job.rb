class Claims::User::CreateAndDeliverJob < ApplicationJob
  queue_as :default

  def perform(school_id:, user_details:)
    school = Claims::School.find(school_id)
    user = school.users.create!(
      first_name: user_details[:first_name],
      last_name: user_details[:last_name],
      email: user_details[:email],
    )

    User::Invite.call(user:, organisation: school)
  end
end
