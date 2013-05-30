require 'spec_helper'

describe Visit::Flow::Breakpoint do

  context "the #each_array_of_events iterator yields" do
    before do
      delete_all_visits
      run_requests_through_factory [
        { url: "http://a", user_id: 11, token: "1111111111111111" },
        { url: "http://b", user_id: 11, token: "1111111111111111" },
        { url: "http://c", user_id: 11, token: "1111111111111111" },
        { url: "http://d", user_id: 11, token: "2222222222222222" },
        { url: "http://e", user_id: 11, token: "2222222222222222", created_at: Time.now+3.hours },
        { url: "http://f", user_id: 11, token: "2222222222222222", created_at: Time.now+3.hours+1.minute },
      ]
    end

    let (:breakpoint) { Visit::Flow::Breakpoint.new }
    let (:a_events) {
      [].tap do |collection|
        breakpoint.each_array_of_events(Visit::Event.scoped) do |a|
          collection << a
        end
      end
    }

    it "array of arrays of events" do
      a_events.should have(3).items
      a_events[0].should be_a_kind_of(Array)
      a_events[0][0].should be_a_kind_of(Visit::Event)
    end

    context "a new array" do
      it "is yielded when there is a change of token" do
        a_events[0].should have(3).items
        a_events[0].first.url.should == "http://a"
        a_events[0].last.url.should == "http://c"
      end

      it "can have just one event" do
        a_events[1].should have(1).items
        a_events[1].first.url.should == "http://d"
      end

      it "is yielded when there is a gap in time between events" do
        a_events[2].should have(2).items
        a_events[2].first.url.should == "http://e"
        a_events[2].last.url.should == "http://f"
      end
    end
  end
end
