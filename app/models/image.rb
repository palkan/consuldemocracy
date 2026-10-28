# typed: strict
class Image < ApplicationRecord
  include Attachable

  sig { returns(T::Hash[Symbol, T::Hash[Symbol, String]]) }
  def self.styles
    {
      large: { resize: "x#{Setting["uploads.images.min_height"]}" },
      medium: { gravity: "center", resize: "300x300^", crop: "300x300+0+0" },
      thumb: { gravity: "center", resize: "140x245^", crop: "140x245+0+0" }
    }
  end

  belongs_to :user
  belongs_to :imageable, polymorphic: true, touch: true

  validates :title, presence: true
  validate :validate_title_length
  validates :user_id, presence: true
  validates :imageable_id, presence: true,         if: :persisted?
  validates :imageable_type, presence: true,       if: :persisted?
  validate :validate_image_dimensions,
           if: ->(image) { image.attachment.attached? && image.attachment.new_record? }

  sig { returns(Integer) }
  def self.max_file_size
    Setting["uploads.images.max_size"].to_i
  end

  sig { returns(T::Array[String]) }
  def self.accepted_content_types
    Setting["uploads.images.content_types"]&.split || ["image/jpeg"]
  end

  sig { returns(String) }
  def self.humanized_accepted_content_types
    Setting.accepted_content_types_for("images").join(", ")
  end

  sig { returns(Integer) }
  def max_file_size
    self.class.max_file_size
  end

  sig { returns(T::Array[String]) }
  def accepted_content_types
    self.class.accepted_content_types
  end

  sig do
    params(style: T.nilable(Symbol))
      .returns(T.any(ActiveStorage::Variant, ActiveStorage::VariantWithRecord))
  end
  def variant(style)
    if style
      attachment.variant(T.must(self.class.styles[style]).merge(strip: true))
    else
      attachment.variant(strip: true)
    end
  end

  private

    sig { returns(Symbol) }
    def association_name
      :imageable
    end

    sig { returns(T.nilable(T.class_of(ApplicationRecord))) }
    def imageable_class
      association_class
    end

    sig { void }
    def validate_image_dimensions
      if accepted_content_types.include?(attachment_content_type)
        return true if imageable_class == Widget::Card

        unless attachment.analyzed?
          attachment_changes["attachment"].upload
          attachment.analyze
        end

        width = attachment.metadata[:width]
        height = attachment.metadata[:height]
        min_width = Setting["uploads.images.min_width"].to_i
        min_height = Setting["uploads.images.min_height"].to_i
        errors.add(:attachment, :min_image_width, required_min_width: min_width) if width < min_width
        errors.add(:attachment, :min_image_height, required_min_height: min_height) if height < min_height
      end
    end

    sig { void }
    def validate_title_length
      if (title = self.title).present?
        title_min_length = Setting["uploads.images.title.min_length"].to_i
        title_max_length = Setting["uploads.images.title.max_length"].to_i

        if title.size < title_min_length
          errors.add(:title, I18n.t("errors.messages.too_short", count: title_min_length))
        end

        if title.size > title_max_length
          errors.add(:title, I18n.t("errors.messages.too_long", count: title_max_length))
        end
      end
    end
end
