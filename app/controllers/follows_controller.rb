# typed: true
class FollowsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource

  sig { void }
  def create
    @follow.save!
    flash.now[:notice] = t("shared.followable.#{followable_translation_key(@follow)}.create.notice")
    render :refresh_follow_button
  end

  sig { void }
  def destroy
    @follow.destroy!
    flash.now[:notice] = t("shared.followable.#{followable_translation_key(@follow)}.destroy.notice")
    render :refresh_follow_button
  end

  private

    sig { returns(ActionController::Parameters) }
    def follow_params
      params.permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      [:followable_type, :followable_id]
    end

    sig { params(follow: Follow).returns(String) }
    def followable_translation_key(follow)
      follow.followable.class.name.parameterize(separator: "_")
    end
end
