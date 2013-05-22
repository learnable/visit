class Visit::Configurable

  def self.labels_match_first
    [
      [  :get, %r{^/articles(?:\?.*|)$},   :articles_index ],
      [  :get, %r{^/articles/(\d+)/(\d+)}, :subarticle     ],
      [  :get, %r{^/articles/(\d+)},       :article        ],
    ]
  end

  def self.ignorable
    [
      /\/courses\/blah.js/,
      /\/system\/blah/,
    ]
  end

end

def new_request_payload_hash opts = {}
  h = {
    :http_method => "GET",
    :url         => "https://earl.io?utm_campaign=qqq",
    :vid         => 111,
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
