require 'spec_helper'

describe Visit::Flow::Ranges do
  let(:user) { create :user }
  let!(:ve1) { create :visit_event, url: "http://e.org/articles", user: user, vid: 100 }
  let!(:ve2) { create :visit_event, url: "http://e.org/articles/1", user: user, vid: 100 }

  before do
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

  it "gives the flows as ve.id ranges" do
    Visit::Flow::Ranges.for_user(user.id).first.should == (ve1.id..ve2.id)
  end
end
