# typed: strict
module FlagActions
  extend ActiveSupport::Concern
  extend T::Helpers
  extend T::Sig

  requires_ancestor { ActionController::Base }

  abstract!

  sig { void }
  def flag
    Flag.flag(current_user, flaggable)

    render "shared/_refresh_flag_actions", locals: { flaggable: flaggable }
  end

  sig { void }
  def unflag
    Flag.unflag(current_user, flaggable)

    render "shared/_refresh_flag_actions", locals: { flaggable: flaggable }
  end

  private

    sig { returns(T.any(Comment, Debate, Proposal, Budget::Investment, Legislation::Proposal)) }
    def flaggable
      if resource_model.to_s == "Budget::Investment"
        instance_variable_get(:@investment)
      elsif resource_model.to_s == "Legislation::Proposal"
        instance_variable_get(:@proposal)
      else
        instance_variable_get("@#{resource_model.to_s.downcase}")
      end
    end

    sig { abstract.returns(T.class_of(ApplicationRecord)) }
    def resource_model; end
end
