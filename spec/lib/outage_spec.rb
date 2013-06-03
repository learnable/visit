require 'spec_helper'

describe Visit::Outage do

  let(:relation) { Visit::Event.scoped }
  let(:outages) { Visit::Outage.new_from_relation(relation) }

  before do
    start_with_visits [
      { url: "http://e.org/articles",     user_id: 10, token: 100, created_at: Time.now - 10.minutes },
      { url: "http://e.org/articles",     user_id: 11, token: 100, created_at: Time.now - 5.minutes },
      { url: "http://e.org/articles/1",   user_id: 12, token: 100, created_at: Time.now - 4.minutes },
      { url: "http://e.org/articles/2/3", user_id: 13, token: 100, created_at: Time.now - 1.minute  },
    ]
  end

  context "when there is a time gap between visit events" do
    it "#new_from_relation returns an array of outages" do
      outages.should have(2).items
    end
    
    it "#first returns the last event before the outage begins" do
      outages.first.first.user_id.should == 10
    end
    it "#last returns the first event after the outage ends" do
      outages.first.last.user_id.should == 11
    end
    it "#start_time_in_words returns the number of minutes ago the outage began" do
      outages.first.start_time_in_words.should =~ /10/
      outages.first.start_time_in_words.should =~ /minutes/
    end
    it "#duration_in_words" do
      outages.first.duration_in_words.should =~ /5/
      outages.first.start_time_in_words.should =~ /minutes/
    end
  end

  context "when there is no time gap between visit events" do
    it "#new_from_relation" do
      Visit::Outage.new_from_relation(relation, 6.minutes).should be_empty
    end
  end
end
