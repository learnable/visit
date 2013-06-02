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

def start_with_visits(a)
  delete_all_visits
  run_requests_through_factory a
end

def run_requests_through_factory(a)
  b = a.map do |h|
      new_request_payload_hash h
    end
  Visit::Factory.new.run b
end

def delete_all_visits
  Visit::Event.delete_all
  Visit::Source.delete_all
  Visit::SourceValue.delete_all
  Visit::Trait.delete_all
  Visit::TraitValue.delete_all
end
