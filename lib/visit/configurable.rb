module Visit
  class Configurable
    class << self
      attr_accessor :bulk_insert_batch_size, :bulk_insert_now, :cache, :cookies_match,
        :case_insensitive_string_comparison, :current_user_id,
        :db_connection, :ignorable, :instrumenter_toggle,
        :token_cookie_mutator, :labels_match_all, :labels_match_first,
        :serialized_queue, :notify, :user_agent_robots

      def bulk_insert_batch_size
        @bulk_insert_batch_size ||= 1
      end

      def bulk_insert_now
        @bulk_insert_now ||= ->() do
          Visit::Factory.new.run
        end
      end

      def cache
        @cache ||= Visit::Cache::Null.new
      end

      def case_insensitive_string_comparison
        @case_insensitive_string_comparison ||= true
      end

      def configure
        yield(self)
      end

      def cookies_match
        @cookies_match ||= [
          /flip_.*/,
        ]
      end

      def current_user_id
        @current_user_id ||= ->(controller) do
          controller.instance_eval { current_user ? current_user.id : nil }
        end
      end

      def db_connection
        @db_connection ||= nil
      end

      def ignorable
        # Before storing an event, the gem matches the http request path against the regexps returned by this method.
        # If there's a match, the request is ignored.
        # Helps avoid filling up the database with requests to polling endpoints.
        #
        # [
        #   /^\/api/
        # ]
        @ignorable ||= []
      end

      def instrumenter_toggle
        @instrumenter_toggle ||= ->(category) do
          category == :deduper
        end
      end

      def token_cookie_mutator
        @token_cookie_mutator ||= :visit_tag_controller # or :application_controller
      end

      def labels_match_all
        # not used:
        # :utm_content

        @labels_match_all ||=
          [ :gclid, :utm_term, :utm_source, :utm_medium, :utm_campaign, :placement ].map do |k|
            [ :get, Regexp.new("[&?]#{k.to_s}=(.*?)(&.*|)$"), k ]
          end
      end

      def labels_match_first
        # The app can override this method to identify requests that are of specific interest.
        # The first match results in a Visit::Trait.
        # Also see Visit::Event::MatcherCollection.
        #
        # eg:
        # [
        #   [ :get,  /^\/contact/,                :contact_prompt  ],
        #   [ :post, /^\/contact\/deliver/,       :contact_deliver ],
        #   [ :get,  /^\/login?.*intended=(.*)$/, :login_prompt    ],
        #   [ :any,  /^\/assessment\/url\/(.*)/,  :url_assessment  ]
        # ]
        #
        @labels_match_first ||= []
      end

      def serialized_queue
        @serialized_queue ||= ->(key) do
          # Visit::SerializedQueue::Redis.new($redis, key)
          Visit::SerializedQueue::Memory.instances(key)
        end
      end

      def notify
        @notify ||= ->(e) do
          Rails.logger.error "ERROR IN VISIT GEM: #{e.to_s}\nBACKTRACE: #{e.backtrace}"
          $stderr.puts "ERROR IN VISIT GEM: #{e.to_s}\nBACKTRACE: #{e.backtrace}"
        end
      end

      def user_agent_robots
        # The http request User-Agent is matched against the regexps in this Array.
        # A Visit::Trait is created if there's a match.
        # Also see Visit::Query::Robot.
        # Handy for distinguishing (some) robot traffic from human traffic.

        @user_agent_robots ||= [
          [ :google,              /Googlebot/i                    ],
          [ :google_ads,          /AdsBot-Google/i                ],
          [ :microsoft_msn,       /msnbot/i                       ],
          [ :microsoft_bing,      /bingbot/i                      ],
          [ :twitter,             /Twitterbot/i                   ],
          [ :tweetmeme,           /TweetmemeBot/i                 ],
          [ :roger,               /rogerbot/i                     ],
          [ :yandex,              /YandexBot/i                    ],
          [ :queryseeker,         /QuerySeekerSpider/i            ],
          [ :wormly,              /WormlyBot/i                    ],
          [ :ruby,                /^Ruby$/i                       ],
          [ :pingdom,             /Pingdom.com_bot/i              ],
          [ :insieve,             /InsieveBot/i                   ],
          [ :undrip,              /undrip/i                       ],
          [ :event_machine,       /EventMachine HttpClient/i      ],
          [ :showyou,             /ShowyouBot/i                   ],
          [ :python_urllib,       /Python-urllib/i                ],
          [ :kimengi,             /Kimengi\/nineconnections.com/i ],
          [ :google_appengine,    /AppEngine-Google/i             ],
          [ :paperli,             /PaperLiBot/i                   ],
          [ :apache_httpclient,   /Apache-HttpClient/i            ],
          [ :pycrawler,           /PyCrawler/i                    ],
          [ :tweetedtimes,        /TweetedTimes Bot/i             ],
          [ :mechanize,           /Mechanize/i                    ],
        ]
      end
    end
  end
end
