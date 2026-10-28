# typed: strict
module FeatureFlags
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  module ClassMethods
    extend T::Sig

    sig { params(name: Symbol, "**": T.untyped).void }
    def feature_flag(name, **)
      T.bind(self, T.class_of(ActionController::Base))
      before_action(**) do
        T.bind(self, FeatureFlags)
        check_feature_flag(name)
      end
    end
  end

  sig { params(name: T.any(String, Symbol)).void }
  def check_feature_flag(name)
    raise FeatureDisabled, name unless Setting["feature.#{name}"] || Setting["process.#{name}"]
  end

  class FeatureDisabled < Exception
    extend T::Sig

    sig { params(name: T.any(String, Symbol)).void }
    def initialize(name)
      @name = name
    end

    sig { returns(String) }
    def message
      "Feature disabled: #{@name}"
    end
  end
end
