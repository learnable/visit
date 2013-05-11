module Visit
  class Configurable
    class << self
      attr_accessor :cache, :create, :current_user_id, :ignorable,
        :labels_match_all, :labels_match_first, :notify,
        :user_agent_robots

      def cache
        @cache ||= Visit::Cache::Null.new
      end

      def configure
        yield(self)
      end

      def create
        # Writes the visit to the database.
        # The app can choose to override this method and delegate to a worker -
        # desirable because this method is called during the Rails request cycle.

        @create ||= -> (o) do
          Visit::Arrival.create o
        end
      end

      def current_user_id
        @current_user_id ||= -> (controller) do
          controller.instance_eval { current_user ? current_user.id : nil }
        end
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

      def labels_match_all
        @labels_match_all ||=
          [ :gclid, :utm_term, :utm_source, :utm_medium, :utm_content, :utm_campaign, :placement ].map do |k|
            [ :get, Regexp.new("[&|?]#{k.to_s}=(.*?)(&.*|)$"), k ]
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

      def notify(e)
        @notify ||= -> (e) do
          Rails.logger.error "ERROR IN VISIT GEM: #{e.to_s}"
        end
      end

      def user_agent_robots
        # The http request User-Agent is matched against the regexps in this Array.
        # A Visit::Trait is created if there's a match.
        # Also see Visit::Query::Robot.
        # Handy for distinguishing (some) robot traffic from human traffic.

        @user_agent_robots ||= [
          /Googlebot/i,
          /Twitterbot/i,
          /TweetmemeBot/i,
          /rogerbot/i,
          /YandexBot/i,
          /msnbot/i,
          /bingbot/i,
          /QuerySeekerSpider/i,
          /WormlyBot/i,
          /^Ruby$/i,
          /Pingdom.com_bot/i,
          /InsieveBot/i,
          /undrip/i,
          /EventMachine HttpClient/i,
          /ShowyouBot/i,
          /Python-urllib/i,
          /Kimengi\/nineconnections.com/i,
          /AppEngine-Google/i,
          /PaperLiBot/i,
          /Apache-HttpClient/i,
          /PyCrawler/i,
          /TweetedTimes Bot/i,
          /AdsBot-Google/i,
          /Mechanize/i,
        ]
      end
    end
  end
end
