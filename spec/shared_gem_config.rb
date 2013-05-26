def new_request_payload_hash opts = {}
  h = {
    :http_method => "GET",
    :url         => "https://earl.io?utm_campaign=qqq",
    :token       => 111,
    :user_id     => nil,
    :user_agent  => "mozilla",
    :remote_ip   => "1.2.3.4",
    :referer     => "http://blah.com",
    :cookies     => { 'a' => 'b', 'c' => 'd' },
    :created_at  => Time.now
  }

  h.merge opts
end

def run_requests_through_factory(a)
  b = a.map do |h|
      new_request_payload_hash h
    end
  Visit::Factory.run b
end
