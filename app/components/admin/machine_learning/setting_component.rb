# typed: strict
class Admin::MachineLearning::SettingComponent < ApplicationComponent
  sig { returns(String) }
  attr_reader :kind

  sig { params(kind: String).void }
  def initialize(kind)
    @kind = kind
    @setting = T.let(nil, T.nilable(Setting))
    @ml_info = T.let(nil, T.nilable(MachineLearningInfo))
  end

  private

    sig { override(allow_incompatible: true).returns(Setting) }
    def setting
      @setting ||= Setting.find_by!(key: "machine_learning.#{kind}")
    end

    sig { returns(T.nilable(MachineLearningInfo)) }
    def ml_info
      @ml_info ||= MachineLearningInfo.for(kind)
    end

    sig { returns(T::Array[String]) }
    def filenames
      T.must(::MachineLearning.data_output_files[T.must(T.must(ml_info).kind).to_sym]).sort
    end

    sig { params(filename: String).returns(String) }
    def data_path(filename)
      ::MachineLearning.data_path(filename)
    end
end
