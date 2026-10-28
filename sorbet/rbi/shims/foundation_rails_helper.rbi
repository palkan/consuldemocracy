# typed: true

# Vendored in vendor/foundation_rails_helper and patched in
# config/initializers/foundation_form_builder.rb; Sorbet doesn't check these paths
module FoundationRailsHelper
  class FormBuilder < ActionView::Helpers::FormBuilder
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper

    sig { params(attribute: T.any(String, Symbol), options: T::Hash[Symbol, T.untyped]).returns(T.nilable(ActiveSupport::SafeBuffer)) }
    def error_for(attribute, options = {}); end

    sig { returns(T::Boolean) }
    def auto_labels; end

    sig { params(args: T.untyped).returns(String) }
    def column_classes(*args); end

    private

    sig { params(attribute: T.any(String, Symbol)).returns(T::Boolean) }
    def error?(attribute); end

    sig { params(object: T.untyped, attribute: T.any(String, Symbol)).returns(String) }
    def default_label_text(object, attribute); end

    sig { params(attribute: T.any(String, Symbol), text: T.untyped, options: T.untyped, block: T.nilable(T.proc.returns(T.untyped))).returns(ActiveSupport::SafeBuffer) }
    def custom_label(attribute, text, options, &block); end

    sig do
      params(
        attribute: T.any(String, Symbol),
        options: T::Hash[T.any(String, Symbol), T.untyped],
        html_options: T.nilable(T::Hash[T.any(String, Symbol), T.untyped]),
        block: T.proc.params(class_options: T::Hash[T.any(String, Symbol), T.untyped]).returns(T.untyped)
      ).returns(ActiveSupport::SafeBuffer)
    end
    def field(attribute, options, html_options = nil, &block); end
  end
end
