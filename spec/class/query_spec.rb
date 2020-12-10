require "hasura_record"

require_relative "../models/post"
require_relative "../models/another"

RSpec.describe 'HasuraRecord quering' do

  let(:hasura_config) do
    HasuraRecord::Config.configure do |config|
      config.schema = {
        data: [
          {name: 'posts', fields: ["id", "autor", "title", "description"]}
        ]
      }
  
      config.prevent_query_execution!
    end
  end

  before do
    hasura_config
  end

  context "Class method" do
    it "#resource_name" do
      expect(Post.resource_name).to eq "posts"
      expect(Another.resource_name).to eq "anothers"
    end

    context "with hasura schema initialized" do
      before do 
        HasuraRecord::Schema.instance.init
      end

      it "#fields" do
        expect(Post.fields).to eq(["autor", "description", "id", "title" ])
      end

      it "#all" do
        expect(Post.all.class).to eq HasuraRecord::Relation
        expect(Post.all.query).to eq "query { posts { autor description id title } }"
      end

      it "#where" do
        expect(Post.where(autor: "Suka").query).to eq 'query { posts(where: {autor: {_eq: "Suka"}}) { autor description id title } }'
      end

      it "#limit" do
        expect(Post.limit(1).query).to eq 'query { posts(limit: 1) { autor description id title } }'
      end

      it "#offset" do
        expect(Post.offset(1).query).to eq 'query { posts(offset: 1) { autor description id title } }'
      end

      it "#where + #limit" do
        expect(Post.where(autor: "Suka").limit(2).query).to eq 'query { posts(where: {autor: {_eq: "Suka"}}, limit: 2) { autor description id title } }'
      end

      it "#find_by" do
        expect(Post.debug.find_by(autor: "Suka").query).to eq 'query { posts(where: {autor: {_eq: "Suka"}}, limit: 1) { autor description id title } }'
      end

      it "#find" do
        expect(Post.debug.find(5).query).to eq 'query { posts(where: {id: {_eq: 5}}, limit: 1) { autor description id title } }'
      end
    end
  end
end