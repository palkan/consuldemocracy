# typed: strict
class Admin::MachineLearning::SettingsComponent < ApplicationComponent
  private

    sig { returns(T::Array[String]) }
    def script_kinds
      @script_kinds ||= T.let(::MachineLearning.script_kinds, T.nilable(T::Array[String]))
    end

    sig { returns(T::Array[String]) }
    def filenames
      ::MachineLearning.data_intermediate_files
    end

    sig { params(filename: String).returns(String) }
    def data_path(filename)
      ::MachineLearning.data_path(filename)
    end
end
