# typed: strict
class Shared::BasicContentComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :record

  sig { returns(T::Boolean) }
  attr_reader :show_tags

  alias_method :show_tags?, :show_tags
  delegate :locale_and_user_status, :namespace, :namespaced_polymorphic_path, :wysiwyg, to: :helpers

  sig { params(record: T.untyped, show_tags: T::Boolean).void }
  def initialize(record, show_tags: true)
    @record = record
    @show_tags = show_tags
  end

  private

    sig { returns(String) }
    def path
      if namespace == "management"
        management_polymorphic_path(record)
      else
        polymorphic_path(record)
      end
    end

    sig { returns(T.nilable(String)) }
    def summary
      if record.respond_to?(:summary)
        tag.p(record.summary)
      else
        wysiwyg(record.description)
      end
    end
end
