##
# Trim old sessions from the database
#
# This is a re-implementation of the Rake task provided by the
# activerecord-session_store gem [1] – but with two differences:
#
#   - It's an Active Job rather than a Rake task. That way we can schedule it
#     to run alongside all the other scheduled jobs, as defined in
#     config/scheduled_jobs.yml
#
#   - The lifetime of a session is determined by the user's authenticated state.
#     If the user's authentication has timed out, so should the rest of their
#     session. So we have consciously coupled this with the authentication
#     model DfESignInUser and its SESSION_TIMEOUT constant.
#
# [1]: https://github.com/rails/activerecord-session_store/blob/734c38f85f169ae26bf6f1af40bf7e1a9e4d34bc/lib/tasks/database.rake#L14-L20

class TrimExpiredSessionsJob < ApplicationJob
  queue_as :default

  def perform
    cutoff_period = DfESignInUser::SESSION_TIMEOUT.ago

    ActiveRecord::SessionStore::Session
      .where("updated_at < ?", cutoff_period)
      .delete_all
  end
end
