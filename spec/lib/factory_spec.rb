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

#   context "for performance testing, with 1000 requests" do
#     before { Visit::Configurable.instrumenter_toggle = ->(category) { true  } }
#     after  { Visit::Configurable.instrumenter_toggle = ->(category) { false } }
#
#     it "imports" do
#       a = (1..500).flat_map do
#         [
#           new_request_payload_hash(url: "http://e.org/articles"),
#           new_request_payload_hash(url: "http://e.org/articles/1")
#         ]
#         end
#       factory_run a
#     end
#   end
end
