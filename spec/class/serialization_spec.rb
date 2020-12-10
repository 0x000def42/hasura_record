require "hasura_record"

require_relative "../models/post"

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
    HasuraRecord::Schema.instance.init
  end

  it "#find" do

  allow_any_instance_of(HasuraRecord::Collection).to receive(:collection).and_return(
    [
      {id: 5, autor: "autor", title: "title", description: "description"}
    ]
  )
    expect(Post.find(5).class).to eq Post
  end



end