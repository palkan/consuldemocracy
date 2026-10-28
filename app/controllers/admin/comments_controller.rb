# typed: true
class Admin::CommentsController < Admin::BaseController
  sig { void }
  def index
    @comments = Comment.sort_by_newest.page(params[:page])
  end
end
