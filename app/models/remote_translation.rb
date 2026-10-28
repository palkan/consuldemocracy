# typed: strict
class RemoteTranslation < ApplicationRecord
  belongs_to :remote_translatable, polymorphic: true

  validates :remote_translatable_id, presence: true
  validates :remote_translatable_type, presence: true
  validates :locale, presence: true
  validates :locale, inclusion: { in: ->(_) { RemoteTranslations::Caller.available_locales }}
  validate :already_translated_resource
  after_commit :enqueue_remote_translation, on: :create

  sig { void }
  def enqueue_remote_translation
    remote_caller.delay.call
  end

  sig { params(resources: T.untyped).returns(T::Array[RemoteTranslation]) }
  def self.for(*resources)
    resources_groups(resources).flatten.select { |resource| translation_empty?(resource) }.map do |resource|
      new(remote_translatable: resource, locale: I18n.locale)
    end
  end

  sig { params(args: T.untyped).returns(T::Array[T.untyped]) }
  def self.resources_groups(*args)
    resources = args.flatten.compact
    feeds = resources.select { |resource| resource.is_a?(Widget::Feed) }

    (resources - feeds) + feeds.map(&:items)
  end

  sig { params(resource: T.untyped).returns(T::Boolean) }
  def self.translation_empty?(resource)
    resource.class.translates? && resource.translations.where(locale: I18n.locale).empty?
  end

  sig { params(remote_translations_params: T.untyped).returns(T::Array[RemoteTranslation]) }
  def self.create_all(remote_translations_params)
    remote_translations_params.map do |remote_translation_params|
      new(remote_translation_params)
    end.reject(&:already_translated?).reject(&:enqueued?).each(&:save!)
  end

  sig { void }
  def already_translated_resource
    if already_translated?
      errors.add(:locale, :already_translated)
    end
  end

  sig { returns(T::Boolean) }
  def enqueued?
    self.class.where(remote_translatable: remote_translatable,
                     locale: locale,
                     error_message: nil).any?
  end

  sig { returns(T::Boolean) }
  def already_translated?
    remote_translatable&.translations&.where(locale: locale).present?
  end

  sig { returns(RemoteTranslations::Caller) }
  def remote_caller
    @remote_caller ||= T.let(RemoteTranslations::Caller.new(self), T.nilable(RemoteTranslations::Caller))
  end
end
