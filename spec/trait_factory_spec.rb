require 'spec_helper'

describe Visit::TraitFactory do
  let(:user) { create :user }

  before do
    create :visit_event, url: "http://e.org/articles", user: user, vid: 100
    create :visit_event, url: "http://e.org/articles/1", user: user, vid: 100
  end

  # Configure the gem
  before :all do
    Visit::Configurable.instance_eval do
      def labels
        [
          {
          :http_method  => :get,
          :re           => /^\/articles$/,
          :label        => :articles_index,
          :has_sublabel => false
        },
          {
          :http_method  => :get,
          :re           => /^\/articles\/\d/,
          :label        => :article,
          :has_sublabel => false
        }
        ]
      end
      def ignorable
        []
      end
    end
  end

  it "creates new traits" do
    expect {
      Visit::TraitFactory.new.run
    }.to change { Visit::Trait.count }.by(2)
  end
end
