# typed: strict
class Admin::Settings::ImagesAndDocumentsTabComponent < ApplicationComponent
  sig { returns(String) }
  def tab
    "#tab-images-and-documents"
  end

  sig { returns(T::Array[String]) }
  def images_settings
    %w[
      uploads.images.title.min_length
      uploads.images.title.max_length
      uploads.images.min_width
      uploads.images.min_height
      uploads.images.max_size
    ]
  end

  sig { returns(T::Array[String]) }
  def documents_settings
    %w[
      uploads.documents.max_amount
      uploads.documents.max_size
    ]
  end
end
