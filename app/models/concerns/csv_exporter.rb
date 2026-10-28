# typed: strict
module CsvExporter
  extend T::Helpers
  extend T::Sig

  requires_ancestor { Object }

  sig { returns(String) }
  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << headers
      records.each do |record|
        comments = comments_in_reading_order(record)

        if comments.any?
          comments.each { |comment| csv << csv_values(record, comment) }
        else
          csv << csv_values(record)
        end
      end
    end
  end

  private

    sig { params(record: T.untyped, comment: T.nilable(Comment)).returns(T::Array[T.nilable(String)]) }
    def csv_values(record, comment = nil)
      record_csv_values(record) + comment_csv_values(comment)
    end

    sig { returns(T::Array[String]) }
    def headers
      model_headers + comment_csv_headers
    end

    sig { params(record: T.untyped).returns(T::Array[T.nilable(String)]) }
    def record_csv_values(record)
      raise "This method must be implemented in class #{self.class.name}"
    end

    sig { returns(T::Array[String]) }
    def model_headers
      raise "This method must be implemented in class #{self.class.name}"
    end

    sig { returns(T::Array[String]) }
    def comment_csv_headers
      [
        I18n.t("admin.comments.index.id"),
        I18n.t("admin.comments.index.author"),
        I18n.t("admin.comments.index.content"),
        Comment.human_attribute_name(:parent_id),
        Comment.human_attribute_name(:created_at)
      ].map { |name| comment_header(name) }
    end

    sig { params(comment: T.nilable(Comment)).returns(T::Array[T.nilable(String)]) }
    def comment_csv_values(comment)
      return empty_comment_csv_values unless comment

      [
        comment.id.to_s,
        comment.author&.email.to_s,
        comment.body,
        comment.parent_id.to_s,
        I18n.l(comment.created_at, format: :datetime)
      ]
    end

    sig { returns(T::Array[String]) }
    def empty_comment_csv_values
      Array.new(comment_csv_headers.size, "")
    end

    sig { params(name: String).returns(String) }
    def comment_header(name)
      "#{Comment.model_name.human} #{name}"
    end

    sig { params(record: T.untyped).returns(T::Array[Comment]) }
    def comments_in_reading_order(record)
      Comment.sort_by_ancestry(record.comments) do |comment, sibling|
        comment.created_at <=> sibling.created_at
      end
    end
end
