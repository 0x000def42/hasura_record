module HasuraRecord
  class Relation

    attr_reader :klass, :collection, :executed, :query_builder

    delegate :to_s, :to_a, to: :collection

    def initialize _klass
      @klass = _klass
      @executed = false
      @query_builder = QueryBuilder.new @klass
      @debug = false
    end

    def query
      @query_builder.query
    end

    def limit param
      @query_builder.limit param
      self
    end

    def offset param
      @query_builder.offset param
      self
    end

    def collection
      Collection.new(klass, @query_builder)
    end

    def where predicates
      @query_builder.where predicates
      if @return_query
        @query_builder.query
      else
        self
      end
    end

    def find_by predicates
      @query_builder.where predicates
      @query_builder.limit 1
      if @debug
        self
      else
        collection.first
      end
    end

    def find param
      find_by(id: param)
    end

    def debug
      @debug = true
      self
    end

    def all
      self
    end

    def select fields
      @query_builder.select fields
      self
    end

    def pluck params

    end

  end
end