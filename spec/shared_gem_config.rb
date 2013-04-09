
# Configure the gem
class Visit::Configurable
  def self.labels
    [{
      :http_method  => :get,
      :re           => /^\/articles(\?.*|)$/,
      :label        => :articles_index,
      :has_sublabel => false
    },
      {
      :http_method  => :get,
      :re           => /^\/articles\/(\d)/,
      :label        => :article,
      :has_sublabel => true
    }
    ]
  end
  def self.ignorable
    [
      /\/courses\/blah.js/,
      /\/system\/blah/,
    ]
  end
end
