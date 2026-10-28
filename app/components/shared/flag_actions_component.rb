# typed: strict
class Shared::FlagActionsComponent < ApplicationComponent
  sig { returns(ApplicationRecord) }
  attr_reader :flaggable

  sig { params(flaggable: ApplicationRecord).void }
  def initialize(flaggable)
    @flaggable = flaggable
  end

  sig { returns(T::Boolean) }
  def render?
    can?(:flag, flaggable)
  end

  private

    sig { returns(T::Boolean) }
    def show_flag_action?
      !flagged?
    end

    sig { returns(T::Boolean) }
    def show_unflag_action?
      flagged?
    end

    sig { returns(T::Boolean) }
    def flagged?
      Flag.flagged?(current_user, flaggable)
    end
end
