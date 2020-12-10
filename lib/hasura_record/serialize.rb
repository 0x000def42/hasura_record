module HasuraRecord
  class Serialize
    def self.instance
      @instance ||= self.new
    end

    def run collection, klass
      collection.map do |elem|
        klass.new(elem).tap do |obj|
          obj.new_record = false
          obj.clear_changes_information
        end
      end
    end
  end
end