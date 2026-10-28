# typed: strict
class AdminLegislationSanitizer < WYSIWYGSanitizer
  sig { returns(T::Array[String]) }
  def allowed_tags
    super + %w[img h1 h4 h5 h6 table thead tbody tr th td]
  end

  sig { returns(T::Array[String]) }
  def allowed_attributes
    super + %w[alt src id]
  end
end
