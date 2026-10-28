# typed: strict
module Admin::LocalCensusRecords::ImportsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(resource: LocalCensusRecord, field: Symbol).returns(T.nilable(ActiveSupport::SafeBuffer)) }
  def errors_for(resource, field)
    if resource.errors.include? field
      tag.div class: "error" do
        resource.errors[field].join(", ")
      end
    end
  end
end
