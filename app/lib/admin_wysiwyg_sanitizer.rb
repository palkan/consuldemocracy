# typed: strict
class AdminWYSIWYGSanitizer < WYSIWYGSanitizer
  sig { returns(T::Array[String]) }
  def allowed_tags
    super + %w[img table caption thead tbody tr th td]
  end

  sig { returns(T::Array[String]) }
  def allowed_attributes
    super + %w[alt src align border cellpadding cellspacing dir style class summary scope id]
  end
end
