# typed: strict
class Shared::TagCloudComponent < ApplicationComponent
  sig { returns(String) }
  attr_reader :taggable_class_name

  sig { params(taggable_class_name: String).void }
  def initialize(taggable_class_name)
    @taggable_class_name = taggable_class_name
  end

  private

    sig { returns(TagCloud) }
    def tag_cloud
      TagCloud.new(taggable_class, params[:search])
    end

    sig { returns(TagCloud::ResourceModel) }
    def taggable_class
      taggable_class_name.constantize
    end
end
