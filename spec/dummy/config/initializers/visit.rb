module Visit
  Visit::Configurable.configure do |c|
    c.labels_match_first = [
      [  :get, %r{^/articles(?:\?.*|)$},   :articles_index ],
      [  :get, %r{^/articles/(\d+)/(\d+)}, :subarticle     ],
      [  :get, %r{^/articles/(\d+)},       :article        ],
    ]

    c.ignorable = [
      /.*\.js/,
      /\/system\/blah/,
    ]

    c.cookies_match = [
      /^a$/,
      /^flip_/
    ]

    c.labels_match_all = c.labels_match_all.push *[
      [ :get, %r{[?&]invite=(\w+)},    :invite        ],
      [ :get, %r{[?&]trait_no_value}, :trait_no_value ],
    ]

    c.redis = $redis
  end
end
