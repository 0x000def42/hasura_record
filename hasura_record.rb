require "graphql/client"
require "graphql/client/http"

module HasuraRecord


  class Base

    def self.resource_name
      @resource_name ||= self.name.underscore.pluralize
    end

    def self.fields_meta
      @fields_meta ||= HasuraRecord.types
      .select {|elem| elem["name"] == resource_name }[0]["fields"]
      .select {|field| field["type"]["kind"] != "OBJECT"}
    end

    def self.fields
      @fields ||= fields_meta.map{|field| field["name"] }
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

        Kernel.const_set(:LOCAL_REQUEST, Client.parse(res))
        result = Client.query(LOCAL_REQUEST)
        if result.errors
          raise result.errors.messages["data"][0]
        else
          result.data.send(resource_name)[0]
        end
      end
    end
  end

  HTTP = GraphQL::Client::HTTP.new("http://hasura:8080/v1/graphql") do
    def headers(context)
      { "x-hasura-admin-secret": "secret" }
    end
  end

  def self.types
    @types ||= JSON.parse(HasuraRecord::Schema.to_json)["data"]["__schema"]["types"]
  end

  
  Schema = GraphQL::Client.load_schema(HTTP)
  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

end