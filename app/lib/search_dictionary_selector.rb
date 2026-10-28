# typed: strict
module SearchDictionarySelector
  SQL_QUERY = T.let("SELECT cfgname FROM pg_ts_config".freeze, String)
  I18N_TO_DICTIONARY = T.let({
    ar: "arabic",
    ca: "catalan",
    de: "german",
    dk: "danish",
    el: "greek",
    en: "english",
    es: "spanish",
    eu: "basque",
    fi: "finnish",
    fr: "french",
    ga: "irish",
    hu: "hungarian",
    id: "indonesian",
    it: "italian",
    lt: "lithuanian",
    nb: "norwegian",
    ne: "nepali",
    nl: "dutch",
    nn: "norwegian",
    pt: "portuguese",
    ro: "romanian",
    ru: "russian",
    sr: "serbian",
    sv: "swedish",
    tr: "turkish",
    yi: "yiddish"
  }.freeze, T::Hash[Symbol, String])

  class << self
    extend T::Sig

    sig { returns(T.nilable(String)) }
    def call
      find_from_i18n_default
    end

    private

      sig { returns(T.nilable(String)) }
      def find_from_i18n_default
        key_to_lookup = T.must(Setting.default_locale.to_s.split("-").first).to_sym

        dictionary = I18N_TO_DICTIONARY[key_to_lookup]
        dictionary ||= "simple"
        available_dictionaries.include?(dictionary) ? dictionary : available_dictionaries.first
      end

      sig { returns(T::Array[String]) }
      def available_dictionaries
        result = ActiveRecord::Base.connection.execute(SQL_QUERY)
        result.to_a.map { |row| row["cfgname"] }
      end
  end
end
