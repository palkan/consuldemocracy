# typed: strict
module RemoteTranslations
  module Llm
    class AvailableLocales
      extend T::Sig

      sig { returns(T::Array[String]) }
      def self.locales
        I18n.available_locales.map(&:to_s)
      end
    end
  end
end
