# typed: true
class DirectUploadsController < ApplicationController
  before_action :authenticate_user!

  skip_authorization_check only: :create

  sig { void }
  def create
    @direct_upload = DirectUpload.new(
      direct_upload_params.merge(user: current_user, attachment: params[:attachment])
    )

    if @direct_upload.save
      render
    else
      render status: :unprocessable_content
    end
  end

  private

    sig { returns(ActionController::Parameters) }
    def direct_upload_params
      params.require(:direct_upload)
            .permit(allowed_params)
    end

    sig { returns(T::Array[T.untyped]) }
    def allowed_params
      [
        :resource, :resource_type, :resource_id, :resource_relation,
        :attachment, :cached_attachment, :title, attachment_attributes: []
      ]
    end
end
