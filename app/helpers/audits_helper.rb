# typed: strict
module AuditsHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionView::Base }

  sig { params(resource: ActiveRecord::Base, field: T.any(String, Symbol), value: T.untyped).returns(String) }
  def truncate_audit_value(resource, field, value)
    truncate(audit_value(resource, field, value), length: 50)
  end

  sig { params(resource: ActiveRecord::Base, field: T.any(String, Symbol), value: T.untyped).returns(String) }
  def audit_value(resource, field, value)
    if value.is_a?(Array)
      value.join(",")
    elsif resource.type_for_attribute(field.to_s).type == :boolean
      resource.class.human_attribute_name("#{field}_#{value}")
    else
      value.to_s
    end
  end
end
