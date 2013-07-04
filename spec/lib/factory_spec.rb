require 'spec_helper'

describe Visit::Factory do
  context "using the default ActiveRecord::Base database connection" do
    it_should_behave_like "Factory"
  end

  context "using a database connection set via Configurable" do
    before do
      @db_connection = Visit::Configurable.db_connection
      Visit::Configurable.db_connection = "visit_test"
    end

    after do
      Visit::Configurable.db_connection = @db_connection
    end

    it_should_behave_like "Factory"
  end

  context "using a SerializedQueue::Redis" do
    before do
      @sq = Visit::Configurable.serialized_queue
      Visit::Configurable.serialized_queue = ->(key) { Visit::SerializedQueue::Redis.new($redis, key) }

     RSpec.configure do |config|
        config.order_groups_and_examples do |list|
          list.sort_by { |item| item.description }
        end
     end
    end

    after { Visit::Configurable.serialized_queue = @sq }

    it_should_behave_like "Factory"

    context "zzz after redis specs" do
      it "hasn't leaked any keys" do
        $redis.keys.count.should == 0
      end
    end
  end

end
