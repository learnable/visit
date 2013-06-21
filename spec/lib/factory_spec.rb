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
end
