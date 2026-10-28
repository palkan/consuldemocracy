# typed: strict
class TagSanitizer
  extend T::Sig

  DISALLOWED_STRINGS = T.let(%w[? < > = /].freeze, T::Array[String])

  sig { params(tag: String).returns(String) }
  def sanitize_tag(tag)
    tag = tag.dup
    DISALLOWED_STRINGS.each do |s|
      tag.gsub!(s, "")
    end
    tag.truncate(TagSanitizer.tag_max_length)
  end

  sig { params(tag_list: T::Array[String]).returns(T::Array[String]) }
  def sanitize_tag_list(tag_list)
    tag_list.map { |tag| sanitize_tag(tag) }
  end

  sig { returns(Integer) }
  def self.tag_max_length
    160
  end
end
