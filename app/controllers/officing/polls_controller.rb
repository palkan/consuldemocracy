# typed: true
class Officing::PollsController < Officing::BaseController
  before_action :verify_booth

  sig { void }
  def index
    user = T.must(current_user)
    @polls = user.poll_officer? ? T.must(user.poll_officer).voting_days_assigned_polls : []
    @polls = @polls.select { |poll| poll.current?(Time.current) || poll.current?(1.day.ago) }
  end

  sig { void }
  def final
    @polls = if T.must(current_user).poll_officer?
               T.must(T.must(current_user).poll_officer).final_days_assigned_polls.select do |poll|
                 T.must(poll.ends_at) > 2.weeks.ago && poll.expired? || T.must(poll.ends_at).today?
               end
             else
               []
             end
  end
end
