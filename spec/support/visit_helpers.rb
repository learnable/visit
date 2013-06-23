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

  b.each do |request_payload_hash|
    if !request_payload_hash[:user_id].nil? && !User.exists?(request_payload_hash[:user_id])
      create :user, id: request_payload_hash[:user_id]
    end
  end

  factory_run b
end

def factory_run(a)
  key = Visit::Helper.random_token

  queue = Visit::SerializedQueue::Memory.instances(key)
  a.each { |rph| queue.rpush rph }

  Visit::Configurable.serialized_queue.call(:enroute).rpush key

  Visit::Factory.new.run
end

def push_onto_filling_queue(rph)
  queue = Visit::Configurable.serialized_queue.call(:filling)

  queue.rpush rph
end

def delete_all_visits
  Visit::Source.delete_all
  Visit::Event.delete_all
  Visit::SourceValue.delete_all
  Visit::Trait.delete_all
  Visit::TraitValue.delete_all
end
