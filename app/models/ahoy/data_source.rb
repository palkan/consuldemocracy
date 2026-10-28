# typed: strict
module Ahoy
  class DataSource
    extend T::Sig

    Data = T.type_alias { T::Hash[T.any(Symbol, String), T::Array[T.untyped]] }

    sig { params(block: T.proc.params(data_source: Ahoy::DataSource).void).returns(Data) }
    def self.build(&block)
      new.tap { |data_source| block.call(data_source) }.build
    end

    # Adds a collection with the datasource
    # Name is the name of the collection and will be showed in the
    # chart
    sig { params(name: String, collection: T::Hash[Date, Integer]).void }
    def add(name, collection)
      collections.push data: collection, name: name
      dates.merge(collection.keys)
    end

    sig { returns(Data) }
    def build
      x = T.let([], T::Array[String])
      data = T.let({ x: x }, Data)
      dates.sort.each do |date|
        # Add the key with a valid date format
        x.push date.strftime("%Y-%m-%d")

        # Add the value for each column, or 0 if not present
        collections.each do |col|
          values = (data[col[:name]] ||= [])
          count = col[:data][date] || 0
          values.push count
        end
      end

      data
    end

    private

      sig { returns(T::Array[T::Hash[Symbol, T.untyped]]) }
      def collections
        @collections ||= T.let([], T.nilable(T::Array[T::Hash[Symbol, T.untyped]]))
      end

      sig { returns(T::Set[Date]) }
      def dates
        @dates ||= T.let(Set.new, T.nilable(T::Set[Date]))
      end
  end
end
