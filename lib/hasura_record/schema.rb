module HasuraRecord
  class Schema

    def self.instance 
      @instance ||= self.new
    end

    def initialized?
      @initialized
    end

    def initialized
      @initialized = false
      @schema = {}
      @mode = nil
    end

    def init
      schema_params = Config.instance.schema
      if schema_params[:url]
        @mode = "remote"
      elsif schema_params[:data]
        @schema = schema_params[:data]
        @mode = "local"
      else
        raise "Set schema_params.url or schema.data"
      end
      @initialized = true
      
    end

    def fields_for resource_name
      (@fields_for ||= {})[resource_name] ||= begin
        if @mode == "local"
          resource = @schema.filter {|resource| resource[:name] == resource_name}[0]
          raise "No resource '#{resource_name}' in schema" unless resource
          resource[:fields].sort!
        elsif @mode == "remote"
          JSON.parse(Client.schema.to_json)["data"]["__schema"]["types"]
          @parsed_types ||= JSON.parse(Client.schema.to_json)["data"]["__schema"]["types"]
          @parsed_types.select {|elem| elem["name"] == resource_name }[0]["fields"]
          .select {|field| field["type"]["kind"] != "OBJECT"}.map{|field| field["name"]}
        else
          raise "Implement remote fields_for!"
        end
      end
    end

  end
end