require "graphql/client"
require "graphql/client/http"

module HasuraRecord
  module Client
    def self.client
      @client ||= GraphQL::Client.new(schema: schema, execute: http)
    end

    def self.http
      @http ||= GraphQL::Client::HTTP.new(Config.instance.schema[:url]) do
        def headers(context)
          { "x-hasura-admin-secret": Config.instance.schema[:secret] }
        end
      end
    end

    def self.schema
      @schema ||= GraphQL::Client.load_schema(http)
    end

    def self.execute query
      begin
        Kernel.const_set(:LOCAL_REQUEST, client.parse(query))
        result = client.query(LOCAL_REQUEST)
        if result.errors.messages.keys.length != 0
          raise query
        end
        result.original_hash["data"]
      rescue => e
        p query
        raise e
      end
    end
  end
end