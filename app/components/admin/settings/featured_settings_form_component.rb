# typed: strict
class Admin::Settings::FeaturedSettingsFormComponent < ApplicationComponent
  sig { returns(Setting) }
  attr_reader :feature

  sig { returns(T.nilable(String)) }
  attr_reader :tab

  # `describedby` comes from the request params when the form is submitted
  sig { returns(T.nilable(T.any(T::Boolean, String))) }
  attr_reader :describedby

  sig { returns(T::Boolean) }
  attr_reader :disabled

  alias_method :describedby?, :describedby
  delegate :enabled?, to: :feature

  sig do
    params(
      feature: Setting,
      tab: T.nilable(String),
      describedby: T.nilable(T.any(T::Boolean, String)),
      disabled: T::Boolean
    ).void
  end
  def initialize(feature, tab: nil, describedby: true, disabled: false)
    @feature = feature
    @tab = tab
    @describedby = describedby
    @disabled = disabled
  end

  private

    sig { returns(String) }
    def text
      if enabled?
        t("shared.yes")
      else
        t("shared.no")
      end
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def options
      {
        data: { disable_with: text },
        "aria-labelledby": dom_id(feature, :title),
        "aria-describedby": (dom_id(feature, :description) if describedby?),
        "aria-pressed": enabled?,
        disabled: disabled
      }
    end

    sig { returns(T::Boolean) }
    def remote?
      !%w[feature.map feature.remote_census feature.sdg].include?(feature.key)
    end
end
