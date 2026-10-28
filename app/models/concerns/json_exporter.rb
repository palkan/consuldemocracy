# typed: strict
module JsonExporter
  extend T::Helpers
  extend T::Sig

  requires_ancestor { Object }

  sig { params(filename: T.any(String, Pathname)).returns(Integer) }
  def to_json_file(filename)
    data = []
    model.find_each { |record| data << json_values(record) }
    File.write(filename, data.to_json)
  end

  private

    sig { params(html_string: T.nilable(String)).returns(T.nilable(String)) }
    def strip_tags(html_string)
      ActionView::Base.full_sanitizer.sanitize(html_string)
    end

    sig { returns(T.class_of(ApplicationRecord)) }
    def model
      raise "This method must be implemented in class #{self.class.name}"
    end

    sig { params(record: T.untyped).returns(T::Hash[Symbol, T.untyped]) }
    def json_values(record)
      raise "This method must be implemented in class #{self.class.name}"
    end
end
