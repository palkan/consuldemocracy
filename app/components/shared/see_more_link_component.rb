# typed: strict
class Shared::SeeMoreLinkComponent < ApplicationComponent
  sig { returns(T.untyped) }
  attr_reader :record

  sig { returns(Symbol) }
  attr_reader :association_name

  sig { returns(T.nilable(Integer)) }
  attr_reader :limit

  sig { params(record: T.untyped, association_name: Symbol, limit: T.nilable(Integer)).void }
  def initialize(record, association_name, limit: nil)
    @record = record
    @association_name = association_name
    @limit = limit
  end

  private

    sig { returns(String) }
    def text
      "#{count_out_of_limit}+"
    end

    sig { returns(String) }
    def url
      polymorphic_path(record)
    end

    sig { returns(String) }
    def title
      t("#{i18n_namespace}.filter.more", count: count_out_of_limit)
    end

    sig { returns(Integer) }
    def count_out_of_limit
      return 0 unless limit

      record.send(association_name).size - limit
    end

    sig { returns(String) }
    def i18n_namespace
      association_name.to_s.tr("_", ".")
    end

    sig { returns(String) }
    def html_class
      "more-#{i18n_namespace.split(".").last}"
    end
end
