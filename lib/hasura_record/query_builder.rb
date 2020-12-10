module HasuraRecord
  class QueryBuilder

    attr_accessor :current_query_node, :where_node, :resource_node

    def initialize klass
      @klass = klass
      @root_node = QueryNode.build("root_query", nil)
      @resource_node = QueryNode.build("collection", @root_node, klass.resource_name)
      @current_query_node = nil
      @selected_fields = false
      @query_block = nil
    end

    def query
      @query ||= begin
        finalize_query
        @root_node.to_s.tap do |_query|
          Log.log _query
        end
      end
    end

    def limit param
      init_query_block
      limit = QueryNode.build("limit", @query_block)
      QueryNode.build("number_value", limit, param)
    end

    def offset param
      init_query_block
      limit = QueryNode.build("offset", @query_block)
      QueryNode.build("number_value", limit, param)
    end

    def init_query_block
      unless @query_block
        @query_block = QueryNode.build("query_block", @resource_node)
      end
    end

    def where predicates
      init_query_block
      if predicates.class == Hash
        unless @where_node
          @where_node = QueryNode.build("where", @query_block)
          @current_query_node = @where_node
        end
        predicates.keys.each do |predicate_key|
          predicate_value = predicates[predicate_key]
          predicate_node = QueryNode.build("query_param", @current_query_node, predicate_key)
          if predicate_value.class == String
            eq_node = QueryNode.build("eq_predicate", predicate_node)
            QueryNode.build("string_value", eq_node, predicate_value)
          elsif predicate_value.class == Integer
            eq_node = QueryNode.build("eq_predicate", predicate_node)
            QueryNode.build("number_value", eq_node, predicate_value)
          else
            raise "#{predicate_value.class} not implemented param type in 'where' method "
          end
          
        end
      else
        raise "#{predicates.class} params not implemented in 'where' method"
      end
    end

    def finalize_query
      unless @selected_fields
        @klass.fields.each do |field|
          QueryNode.build("property", @resource_node, field)
        end
      end
    end

    def select fields
      @selected_fields = true
      fields.each do |field|
        QueryNode.build("property", @resource_node, field)
      end
    end
  end
end