require "active_record"

module HasuraRecord
  class Base

    include ActiveModel::Model
    include ActiveModel::Dirty
    include HasuraHelpers::ClassDelegate

    attr_accessor :new_record

    @new_record = true

    def new_record?
      @new_record
    end

    delegate_class :all, :limit, :find_by, :where, :find, :select, :offset, :debug, to: :relation

    def self.relation
      Relation.new self
    end


    def self.resource_name
      @resource_name ||= self.name.underscore.pluralize
    end

    def save
      create_or_update
    end

    def create_or_update
      result = new_record? ? create : update
      result != false
    end

    def create
      raise "Create not implemented"
    end

    def changes_to_query
      changes.map{|k, v| "#{k}: \"#{v[1]}\"" }.join(", ")
    end

    def update
      mutation = "mutation { update_#{self.class.resource_name}_by_pk ( pk_columns: {id: \"#{id}\"}, _set: { #{changes_to_query} }) {id} }"
      if Config.instance.query_execution
        Client.execute mutation
      end
      Log.log mutation
    end

    def self.fields
      @fields ||= begin
        if Schema.instance.initialized?
          Schema.instance.fields_for(resource_name).tap do |fields|
            p fields
            p "!!!!!!!!!!!!!!!"
            fields.each do |field|
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
          end
        else
          raise "Execute 'HasuraRecord::Schema.instance.init' before using hasura engine"
        end
      end
    end
  end
end