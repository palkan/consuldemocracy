# typed: strict
module RemoteTranslations::Microsoft::SentencesParser
  extend T::Sig

  sig { params(text: String).returns(Integer) }
  def detect_split_position(text)
    limit = RemoteTranslations::Microsoft::Client::CHARACTERS_LIMIT_PER_REQUEST
    minimum_valid_index = text.size - limit
    valid_point = T.must(text[minimum_valid_index..text.size]).index(".")
    valid_whitespace = T.must(text[minimum_valid_index..text.size]).index(" ")

    get_split_position(valid_point, valid_whitespace, minimum_valid_index)
  end

  sig do
    params(
      valid_point: T.nilable(Integer),
      valid_whitespace: T.nilable(Integer),
      minimum_valid_index: Integer
    ).returns(Integer)
  end
  def get_split_position(valid_point, valid_whitespace, minimum_valid_index)
    split_position = minimum_valid_index
    if valid_point.present? || valid_whitespace.present?
      valid_position = T.must(valid_point.presence || valid_whitespace)
      split_position = split_position + valid_position
    end
    split_position
  end

  sig { params(texts: T::Array[String]).returns(Integer) }
  def characters_count(texts)
    texts.sum(&:size)
  end
end
