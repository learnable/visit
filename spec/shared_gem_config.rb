class Visit::Configurable

  def self.labels
    [
      [  :get, /^\/articles(\?.*|)$/, :articles_index, false ],
      [  :get, /^\/articles\/(\d)/,   :article,         true ]
    ]
  end

  def self.ignorable
    [
      /\/courses\/blah.js/,
      /\/system\/blah/,
    ]
  end

end
