module Visit
  Visit::Configurable.configure do |c|
    c.cookies_match = [
      /^a$/,
      /^flip_/
    ]

    c.ignorable = [
      /.*\.js/,
      /\/system\/blah/,
    ]

    c.labels_match_all = c.labels_match_all.push *[
      [ :get, %r{[?&]invite=(\w+)},   :invite         ],
      [ :get, %r{[?&]trait_no_value}, :trait_no_value ],
    ]

    c.labels_match_first = [
      [  :get, %r{^/articles(?:\?.*|)$},   :articles_index ],
      [  :get, %r{^/articles/(\d+)/(\d+)}, :subarticle     ],
      [  :get, %r{^/articles/(\d+)},       :article        ],
    ]
  end
end
