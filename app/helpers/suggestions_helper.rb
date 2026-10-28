# typed: strict
module SuggestionsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(record: ActiveRecord::Base).returns(T.nilable(T::Hash[Symbol, String])) }
  def suggest_data(record)
    return unless record.new_record?

    {
      js_suggest_result: "js_suggest_result",
      js_suggest: ".js-suggest",
      js_url: polymorphic_path(record.class, action: :suggest)
    }
  end
end
