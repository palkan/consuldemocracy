# typed: strict
class Shared::DownloadCsvLinkComponent < ApplicationComponent
  sig { returns(Symbol) }
  attr_reader :path_helper

  sig { params(path_helper: Symbol).void }
  def initialize(path_helper:)
    @path_helper = path_helper
  end

  private

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def csv_params
      params
        .to_unsafe_h
        .symbolize_keys
        .merge(format: :csv)
        .except(:page)
    end

    sig { returns(String) }
    def csv_path
      send(path_helper, csv_params)
    end
end
