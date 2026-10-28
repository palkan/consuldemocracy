# typed: strict
class WYSIWYGSanitizer
  extend T::Sig

  sig { returns(T::Array[String]) }
  def allowed_tags
    %w[p ul ol li strong em u s a h2 h3]
  end

  sig { returns(T::Array[String]) }
  def allowed_attributes
    %w[href]
  end

  sig { params(html: T.nilable(String)).returns(T.nilable(ActiveSupport::SafeBuffer)) }
  def sanitize(html)
    ActionController::Base.helpers.sanitize(html, tags: allowed_tags, attributes: allowed_attributes)
  end
end
