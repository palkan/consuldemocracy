# typed: true
class Admin::Poll::ResultsController < Admin::Poll::BaseController
  before_action :load_poll

  sig { void }
  def index
    @partial_results = @poll.partial_results
  end

  private

    sig { void }
    def load_poll
      @poll = ::Poll.includes(:questions).find(params[:poll_id])
    end
end
