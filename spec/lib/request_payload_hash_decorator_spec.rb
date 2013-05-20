require 'spec_helper'

describe Visit::RequestPayloadHashDecorator do
  subject {
    h = {
      :http_method => "GET",
      :url         => "http://example.com",
      :vid         => 111,
      :user_id     => 22,
      :user_agent  => "mozilla",
      :remote_ip   => 333,
      :referer     => "http://blah.com",
      :cookies     => { a: :b, c: :d },
      :created_at  => Time.now
    }

    Visit::RequestPayloadHashDecorator.new h
  }

  its "to_values" do
    should == [ "http://example.com", "mozilla", "http://blah.com", "a", "b", "c", "d" ]
  end

  pending "to_pairs" do
  end

end
