# typed: strict
class Admin::SearchComponent < ApplicationComponent
  sig { returns(String) }
  attr_reader :label

  sig { returns(T::Hash[Symbol, T.untyped]) }
  attr_reader :form_options

  sig { params(label: String, url: T.nilable(String), form_options: T.untyped).void }
  def initialize(label:, url: nil, **form_options)
    @label = label
    @url = url
    @form_options = form_options
  end

  sig { returns(String) }
  def url
    @url || request.path
  end

  private

    sig { returns(T.untyped) }
    def search_terms
      params[:search]
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def options
      { method: :get, role: "search" }.merge(form_options)
    end

    sig { returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def hidden_current_filter_tag
      hidden_field_tag(:filter, current_filter) if current_filter
    end

    sig { returns(T.nilable(String)) }
    def current_filter
      if helpers.respond_to?(:current_filter)
        helpers.current_filter
      end
    end
end
