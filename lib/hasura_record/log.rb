module HasuraRecord
  class Log
    @queries = []

    def self.log string
      @queries << string
    end

    def self.queries
      @queries
    end
  end
end