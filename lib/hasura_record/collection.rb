module HasuraRecord
  class Collection

    attr_accessor :collection, :klass, :query_builder

    delegate :each, :to_a, :filter, :map, :to_s, :first, to: :serialized_collection
    delegate :query, to: :query_builder

    def initialize klass, query_builder
      @klass = klass
      @query_builder = query_builder
      if Config.instance.query_execution
        result = Client.execute(query_builder.query)
        @collection = result[klass.resource_name]
      else
        query_builder.query
        @collection = []
      end

    end

    def serialized_collection
      @serialized_collection = Serialize.instance.run(collection, klass)
    end

    def all
      self
    end
  end
end