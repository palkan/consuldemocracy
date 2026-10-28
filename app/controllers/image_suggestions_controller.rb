# typed: true
class ImageSuggestionsController < ApplicationController
  before_action :authenticate_user!
  skip_authorization_check

  rate_limit to: 10,
             within: 15.minutes,
             by: lambda {
               T.bind(self, ImageSuggestionsController)
               T.must(current_user).id
             },
             only: :create,
             with: lambda {
               T.bind(self, ImageSuggestionsController)
               render_rate_limit_response
             }

  sig { void }
  def create
    @suggestions = ImageSuggestions::Llm::Client.call(
      title: image_suggestion_params[:title],
      description: image_suggestion_params[:description]
    )

    respond_to do |format|
      format.js
    end
  end

  sig { void }
  def attach
    begin
      attachment = ImageSuggestions::Pexels.download(params[:id])
    rescue ImageSuggestions::Pexels::PexelsError, Pexels::APIError => e
      return render json: { errors: e.message }, status: :unprocessable_content
    end

    @direct_upload = DirectUpload.new(
      resource_type: params[:resource_type],
      resource_id: params[:resource_id],
      resource_relation: "image",
      attachment: attachment,
      title: params[:title],
      user: current_user
    )

    if @direct_upload.save
      render "direct_uploads/create"
    else
      render "direct_uploads/create", status: :unprocessable_content
    end
  end

  private

    sig { void }
    def render_rate_limit_response
      @suggestions = ImageSuggestions::Llm::Client::Response.new
      @suggestions.errors << I18n.t("images.errors.messages.rate_limit_exceeded")

      respond_to do |format|
        format.js { render :create }
      end
    end

    sig { returns(T.any(ActionController::Parameters, T::Hash[T.untyped, T.untyped])) }
    def image_suggestion_params
      @image_suggestion_params ||= params.require(params[:resource_type].parameterize.underscore)
                                         .permit(translations_attributes: [:title, :description])
                                         .fetch(:translations_attributes, {})
                                         .values.first || {}
    end
end
