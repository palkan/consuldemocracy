# typed: strict
class Layout::RemoteTranslationsButtonComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :record_or_records

  delegate :current_order, to: :helpers

  sig { params(record_or_records: T.untyped).void }
  def initialize(record_or_records)
    @record_or_records = record_or_records
    @remote_translations = T.let(nil, T.nilable(T::Array[RemoteTranslation]))
  end

  sig { returns(T::Array[RemoteTranslation]) }
  def remote_translations
    @remote_translations ||= detect_remote_translations
  end

  sig { returns(T::Boolean) }
  def render?
    remote_translations.present? &&
      RemoteTranslations::Caller.available_locales.include?(I18n.locale.to_s)
  end

  sig { returns(T::Array[RemoteTranslation]) }
  def detect_remote_translations
    return [] unless remote_translation_enabled?

    if record_or_records.respond_to?(:comments)
      RemoteTranslation.for([record_or_records], comments)
    else
      RemoteTranslation.for(record_or_records)
    end
  end

  private

    sig { returns(T::Boolean) }
    def translations_in_progress?
      remote_translations.any?(&:enqueued?)
    end

    sig { returns(T::Array[Comment]) }
    def comments
      CommentTree.new(record_or_records, params[:page], current_order).comments
    end

    sig { returns(T::Boolean) }
    def remote_translation_enabled?
      RemoteTranslations::Caller.configured?
    end
end
