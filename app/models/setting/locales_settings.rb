# typed: strict
class Setting
  class LocalesSettings
    extend T::Sig
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :enabled, array: true, default: -> { Setting.enabled_locales }
    attribute :default, default: -> { Setting.default_locale }

    sig { returns(T::Boolean) }
    def persisted?
      true
    end

    sig { params(attributes: T.untyped).void }
    def update(attributes)
      assign_attributes(attributes)

      Setting.transaction do
        Setting["locales.default"] = default
        Setting["locales.enabled"] = [default, *enabled].join(" ")
      end
    end
    alias_method :update!, :update
  end
end
