class Visit::Configurable

  def self.labels_match_first
    [
      [  :get, %r{^/articles(\?.*|)$}, :articles_index ],
      [  :get, %r{^/articles\/(\d+)},  :article        ]
    ]
  end

  def self.ignorable
    [
      /\/courses\/blah.js/,
      /\/system\/blah/,
    ]
  end

end
