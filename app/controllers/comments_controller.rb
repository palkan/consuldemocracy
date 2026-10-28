# typed: true
class CommentsController < ApplicationController
  include FlagActions

  before_action :authenticate_user!, only: [:create, :hide]
  before_action :load_commentable, only: :create
  before_action :verify_resident_for_commentable!, only: :create
  before_action :verify_comments_open!, only: [:create]
  before_action :build_comment, only: :create

  load_and_authorize_resource
  respond_to :html, :js

  sig { void }
  def create
    if @comment.save
      CommentNotifier.new(comment: @comment).process
      add_notification @comment
      EvaluationCommentNotifier.new(comment: @comment).process if send_evaluation_notification?
    else
      render :new
    end
  end

  sig { void }
  def show
    @comment = Comment.find(params[:id])
    if @comment.valuation && @comment.author != current_user
      raise ActiveRecord::RecordNotFound
    end
  end

  sig { void }
  def hide
    @comment.hide
  end

  private

    sig { override.returns(T.class_of(Comment)) }
    def resource_model
      Comment
    end

    sig { returns(ActionController::Parameters) }
    def comment_params
      params.require(:comment).permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      [
        :commentable_type, :commentable_id, :parent_id,
        :body, :as_moderator, :as_administrator, :valuation
      ]
    end

    sig { void }
    def build_comment
      @comment = Comment.build(@commentable, T.must(current_user), comment_params[:body],
                               comment_params[:parent_id].presence,
                               comment_params[:valuation])
      check_for_special_comments
    end

    sig { void }
    def check_for_special_comments
      if administrator_comment?
        @comment.administrator_id = T.must(T.must(current_user).administrator).id
      elsif moderator_comment?
        @comment.moderator_id = T.must(T.must(current_user).moderator).id
      end
    end

    sig { void }
    def load_commentable
      @commentable = Comment.find_commentable(comment_params[:commentable_type],
                                              comment_params[:commentable_id])
    end

    sig { returns(T::Boolean) }
    def administrator_comment?
      ["1", true].include?(comment_params[:as_administrator]) &&
        can?(:comment_as_administrator, @commentable)
    end

    sig { returns(T::Boolean) }
    def moderator_comment?
      ["1", true].include?(comment_params[:as_moderator]) &&
        can?(:comment_as_moderator, @commentable)
    end

    sig { params(comment: Comment).void }
    def add_notification(comment)
      notifiable = comment.reply? ? comment.parent : comment.commentable
      notifiable_author_id = notifiable&.author_id
      if notifiable_author_id.present? && notifiable_author_id != comment.author_id
        Notification.add(notifiable.author, notifiable)
      end
    end

    sig { void }
    def verify_resident_for_commentable!
      return if T.must(current_user).administrator? || T.must(current_user).moderator?

      if @commentable.respond_to?(:comments_for_verified_residents_only?) &&
         @commentable.comments_for_verified_residents_only?
        verify_resident!
      end
    end

    sig { void }
    def verify_comments_open!
      return if T.must(current_user).administrator? || T.must(current_user).moderator?

      if @commentable.respond_to?(:comments_closed?) && @commentable.comments_closed?
        redirect_to polymorphic_path(@commentable), alert: t("comments.comments_closed")
      end
    end

    sig { returns(T.nilable(T.any(T::Boolean, String))) }
    def send_evaluation_notification?
      @comment.valuation && Setting["feature.valuation_comment_notification"]
    end
end
