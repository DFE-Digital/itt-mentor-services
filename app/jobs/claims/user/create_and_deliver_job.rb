class Claims::User::CreateAndDeliverJob < ApplicationJob
  queue_as :default

  def perform(school_id:, user_details:)
    school = Claims::School.find(school_id)
    return if school.users.find_by(email: user_details[:email])

    user = Claims::User.find_or_create_by!(email: user_details[:email]) do |u|
      u.first_name = user_details[:first_name]
      u.last_name = user_details[:last_name]
    end

    user.user_memberships.create!(organisation: school)

    User::Invite.call(user:, organisation: school)
  end
end
