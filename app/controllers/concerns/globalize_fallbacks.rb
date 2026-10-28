# typed: strict
module GlobalizeFallbacks
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  included do
    before_action :initialize_globalize_fallbacks
  end

  private

    sig { void }
    def initialize_globalize_fallbacks
      Globalize.set_fallbacks_to_all_available_locales
    end
end
