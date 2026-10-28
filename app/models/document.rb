# typed: strict
class Document < ApplicationRecord
  include Attachable

  belongs_to :user
  belongs_to :documentable, polymorphic: true, touch: true

  validates :title, presence: true
  validates :user_id, presence: true
  validates :documentable_id, presence: true,         if: :persisted?
  validates :documentable_type, presence: true,       if: :persisted?

  before_save :remove_metadata

  scope :admin, -> { where(admin: true) }

  sig { returns(String) }
  def self.humanized_accepted_content_types
    Setting.accepted_content_types_for("documents").join(", ")
  end

  sig { returns(String) }
  def humanized_content_type
    T.must(T.must(attachment_content_type).split("/").last).upcase
  end

  sig { returns(Integer) }
  def max_file_size
    T.must(documentable_class).max_file_size
  end

  sig { returns(T::Array[String]) }
  def accepted_content_types
    T.must(documentable_class).accepted_content_types
  end

  private

    sig { returns(Symbol) }
    def association_name
      :documentable
    end

    sig { returns(T.nilable(Documentable::ClassMethods)) }
    def documentable_class
      T.cast(association_class, T.nilable(Documentable::ClassMethods))
    end

    sig { void }
    def remove_metadata
      return unless attachment.attached?

      attachment_path = ActiveStorage::Blob.service.path_for(attachment.key)
      Exiftool.new(attachment_path, "-all:all=")
    rescue Exiftool::ExiftoolNotInstalled, Exiftool::NoSuchFile
      nil
    end
end
