# typed: strict
module SearchCache
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ApplicationRecord }

  included do
    after_save :calculate_tsvector
  end

  sig { returns(Integer) }
  def calculate_tsvector
    model = T.cast(self.class, ActsAsParanoidAliases::ClassMethods)
    model.with_hidden.where(id: id).update_all("tsv = (#{searchable_values_sql})")
  end

  private

    sig { returns(String) }
    def searchable_values_sql
      searchable_values
        .select { |k, _| k.present? }
        .map { |value, weight| set_tsvector(value, weight) }
        .join(" || ")
    end

    sig { params(value: T.untyped, weight: String).returns(String) }
    def set_tsvector(value, weight)
      dict = quote(SearchDictionarySelector.call)
      "setweight(to_tsvector(#{dict}, unaccent(coalesce(#{quote(strip_html(value))}, ''))), #{quote(weight)})"
    end

    sig { params(value: T.untyped).returns(String) }
    def quote(value)
      ActiveRecord::Base.connection.quote(value)
    end

    sig { params(value: T.untyped).returns(T.nilable(String)) }
    def strip_html(value)
      ActionController::Base.helpers.sanitize(value, tags: [])
    end
end
