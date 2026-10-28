# typed: true
class Admin::TagsController < Admin::BaseController
  before_action :find_tag, only: :destroy
  before_action :tags, only: [:index, :create]

  respond_to :html, :js

  sig { void }
  def index
    @tag = Tag.category.new
  end

  sig { void }
  def create
    @tag = Tag.find_or_initialize_by(tag_params)

    save_and_update = @tag.save && @tag.update!(kind: "category")

    if save_and_update
      redirect_to admin_tags_path
    else
      render :index
    end
  end

  sig { void }
  def destroy
    @tag.destroy!
    redirect_to admin_tags_path
  end

  private

    sig { returns(Tag::PrivateRelation) }

    def tags
      @tags ||= Tag.category.page(params[:page])
    end

    sig { returns(ActionController::Parameters) }
    def tag_params
      params.require(:tag).permit(:name)
    end

    sig { void }
    def find_tag
      @tag = Tag.category.find(params[:id])
    end
end
