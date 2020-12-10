require "hasura_record"

require_relative "../models/post"
require_relative "../models/another"

RSpec.describe 'HasuraRecord quering' do

    HasuraRecord::Config.configure do |config|
      config.schema = {
        data: [
          {name: 'posts', fields: ["id", "autor", "title", "description"]}
        ]
      }
  
      config.prevent_query_execution!
    end

    HasuraRecord::Schema.instance.init


  it "find and edit attribute" do

    allow_any_instance_of(HasuraRecord::Collection).to receive(:collection).and_return(
      [
        {id: 5, autor: "autor", title: "title", description: "description"}
      ]
    )

    post = Post.find(5)

    post.autor = "autor2"
    post.save


    expect(HasuraRecord::Log.queries.last).to eq "mutation { update_posts_by_pk ( pk_columns: {id: \"5\"}, _set: { autor: \"autor2\" }) {id} }"
  end



end