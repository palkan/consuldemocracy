# typed: true
class DirectUpload
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  extend T::Sig

  sig { returns(T.untyped) }
  attr_accessor :resource, :resource_id, :attachment

  sig { returns(T.nilable(String)) }
  attr_accessor :resource_type, :resource_relation, :cached_attachment, :title

  sig { returns(T.nilable(T.any(Image, Document))) }
  attr_accessor :relation

  sig { returns(T.nilable(User)) }
  attr_accessor :user

  validates :attachment, :resource_type, :resource_relation, :user, presence: true
  validate :parent_resource_attachment_validations,
           if: ->(upload) do
             [upload.attachment, upload.resource_type, upload.resource_relation, upload.user].all?(&:present?)
           end

  sig { params(attributes: T.any(T::Hash[T.untyped, T.untyped], ActionController::Parameters)).void }
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end

    if @resource_type.present? &&
       @resource_relation.present? &&
       (@attachment.present? || @cached_attachment.present?)
      @resource = @resource_type.constantize.find_or_initialize_by(id: @resource_id)

      # Refactor
      @relation = if @resource.respond_to?(:images) &&
                     (@attachment.present? && !@attachment.content_type.match(/pdf/) ||
                      @cached_attachment.present?)
                    @resource.images.send(:build, relation_attributtes)
                  elsif @resource.class.reflections[@resource_relation].macro == :has_one
                    @resource.send("build_#{resource_relation}", relation_attributtes)
                  else
                    @resource.send(@resource_relation).build(relation_attributtes)
                  end

      T.must(@relation).user = user
    end
  end

  sig { void }
  def save_attachment
    relation = T.must(@relation)
    relation.attachment.blob.save!
    relation.attachment_changes["attachment"].upload
  end

  sig { returns(T.nilable(TrueClass)) }
  def save
    relation = T.must(@relation)
    relation.title = relation.title.presence || relation.attachment_file_name

    if valid?
      save_attachment
      relation.set_cached_attachment_from_attachment
      true
    end
  end

  sig { returns(T::Boolean) }
  def persisted?
    false
  end

  private

    sig { void }
    def parent_resource_attachment_validations
      relation = T.must(@relation)
      relation.valid?

      if relation.errors.key? :attachment
        errors.add(:attachment, relation.errors.full_messages_for(:attachment))
      end
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def relation_attributtes
      {
        attachment: @attachment,
        cached_attachment: @cached_attachment,
        user: @user,
        title: @title
      }
    end
end
