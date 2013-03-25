require 'spec_helper'

describe Visit::Flow do
  let(:user) { create :user }
  let(:range) { Visit::Flow::Ranges.for_user(user.id).first }
  let(:flow) { Visit::Flow.new(range) }

  before do
    create :visit_event, url: "http://e.org/articles", user: user, vid: 100
    create :visit_event, url: "http://e.org/articles/1", user: user, vid: 100
    # Run factory to assign labels to visit events in order for Flow to
    # register the events
    Visit::TraitFactory.new.run
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


  it "shows flow steps" do
    flow.steps.should == "articles_index -> article"
  end
end
