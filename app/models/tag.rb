# typed: strict
class Tag < ActsAsTaggableOn::Tag
  extend T::Sig

  sig { returns(T::Boolean) }
  def self.machine_learning?
    MachineLearning.enabled? && Setting["machine_learning.tags"].present?
  end
end
