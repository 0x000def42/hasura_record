module HasuraRecord
  class Config

    attr_reader :query_execution 
    attr_accessor :schema

    def initialize
      @query_execution = true
      @schema = {}
    end

    def self.configure
      yield instance
    end

    def self.instance
      @instance ||= self.new
    end

    def prevent_query_execution!
      @query_execution = false
    end
  end
end