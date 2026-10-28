# typed: true
class TranslationsFieldsFormBuilder < ConsulFormBuilder
  sig { returns(T.nilable(Symbol)) }
  def locale
    @object.locale
  end
end
