# typed: strict
class I18nContentTranslation < ApplicationRecord
  sig { returns(T::Array[Symbol]) }
  def self.existing_locales
    distinct.pluck(:locale).map(&:to_sym)
  end
end
