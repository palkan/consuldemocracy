# typed: strict
module SDG::OptionsForSelect
  extend ActiveSupport::Concern
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ApplicationComponent }

  sig { params(selected_code: T.nilable(String)).returns(ActiveSupport::SafeBuffer) }
  def goal_options(selected_code = nil)
    options_from_collection_for_select(SDG::Goal.order(:code), :code, :code_and_title, selected_code)
  end

  sig { params(selected_code: T.nilable(String)).returns(ActiveSupport::SafeBuffer) }
  def target_options(selected_code = nil)
    targets = SDG::Target.all + SDG::LocalTarget.all

    options_from_collection_for_select(targets.sort, :code, :code_and_title, selected_code)
  end
end
