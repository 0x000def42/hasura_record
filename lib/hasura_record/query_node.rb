module HasuraRecord
  class QueryNode

    # root_query
    # collection
    # where

    # query_param

    # string_value
    # number_value

    # eq_predicate

    attr_accessor :children, :value, :type

    def self.build type, parent, value=nil
      obj = self.new type, parent, value
      parent.children << obj if parent
      obj
    end

    def initialize type, parent, value
      @children = []
      @type = type

      @value = value
      @parent = parent
    end

    def to_s
      case @type
      when "root_query"
        "query { #{children.map(&:to_s).join(" ")} }"
      when "collection"
        query_block = children.filter { |node| node.type == "query_block" }[0]
        if query_block.present?
          "#{value}(#{query_block.children.map(&:to_s).join(", ")}) { #{children.filter {|node| node.type != "query_block" }.map(&:to_s).join(" ")} }"
        else
          "#{value} { #{children.filter {|node| node.type != "query_block" }.map(&:to_s).join(" ")} }"
        end
      when "property"
        "#{value}"
      when "where"
        "where: {#{children.map(&:to_s).join(", ")}}"
      when "limit"
        "limit: #{children[0]&.to_s}"
      when "offset"
        "offset: #{children[0]&.to_s}"
      when "query_param"
        "#{value}: {#{children.map(&:to_s).join(", ")}}"
      when "eq_predicate"
        "_eq: #{children[0]&.to_s}"
      when "string_value"
        "\"#{value}\""
      when "number_value"
        "#{value}"        
      else
        raise "#{@type} not implemented as graphql query node type"
      end
    end
  end
end