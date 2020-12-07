require "graphql/client"
require "graphql/client/http"

module HasuraRecord


  class Base

    include ActiveModel::Model
    include ActiveModel::Dirty

    def self.resource_name
      @resource_name ||= self.name.underscore.pluralize
    end

    def self.fields_meta
      @fields_meta ||= HasuraRecord.types
      .select {|elem| elem["name"] == resource_name }[0]["fields"]
      .select {|field| field["type"]["kind"] != "OBJECT"}
    end

    def save
      # TODO
    end

    def self.fields
      @fields ||= begin 
        _fields = fields_meta.map{|field| field["name"] }
        _fields.each do |field|
          self.class_eval <<-EVAL

            define_attribute_methods :#{field}

            def #{field}
              @#{field}
            end

            def #{field}= value
              #{field}_will_change! unless value == @#{field}
              @#{field} = value
            end
          EVAL
        end
        _fields
      end
    end

    def self.find_by params
      undefined_field = params.keys.select { |param| fields.index(param.to_s) == nil }[0]
      if undefined_field
        raise "Undefined field #{undefined_field} in #{self.name}"
      else

        query =  <<-'GRAPHQL'
          query {
            $resource(where: {$query}) {
              $fields
            }
          }
        GRAPHQL

        query_params = params
        .to_a
        .map{ |param| "#{param[0]}: {_eq: \"#{param[1]}\"}" }
        .join(", ")

        res = query
        .gsub("$resource", resource_name)
        .gsub("$fields", fields.join(" "))
        .gsub("$query", query_params )
        Kernel.const_set(:LOCAL_REQUEST, Client.client.parse(res))
        result = Client.client.query(LOCAL_REQUEST)
   
        if !result.data.send(resource_name)
          raise result.errors.messages["data"][0]
        else
          elem = result.data.send(resource_name)[0]
          if elem
            res = self.new(elem.to_h)
            res.clear_changes_information
            res
          else
            nil
          end
        end
      end
    end
  end

  module Client
    def self.client
      @client ||= GraphQL::Client.new(schema: schema, execute: http)
    end

    def self.http
      @http ||= GraphQL::Client::HTTP.new("http://hasura:8080/v1/graphql") do
        def headers(context)
          { "x-hasura-admin-secret": "secret" }
        end
      end
    end

    def self.schema
      @schema ||= GraphQL::Client.load_schema(http)
    end
  end

  def self.types
    @types ||= JSON.parse(Client.schema.to_json)["data"]["__schema"]["types"]
  end

end