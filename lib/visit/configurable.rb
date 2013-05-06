module Visit
  class Configurable
    class << self
      attr_accessor :notifier, :current_user_alias, 
        :ignorable, :labels_match_first, :labels_match_all, 
        :user_agent_robots, :async_library, :async_queue_name, 
        :requests_interceptor_enabled, :process_unintercepted_data
      
      def configure
        yield(self)
      end

      # Should requests in the application be intercepted by the gem?
      def requests_interceptor_enabled
        @requests_interceptor_enabled ||= true
      end

      # Should the gem process data that was collected by other means (not by interception)
      def process_unintercepted_data
        @process_unintercepted_data ||= true
      end

      def current_user_alias
        @current_user_alias ||= :current_user
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

      def labels_match_all
        @labels_match_all ||=
          [
            [:get, /[&|?]gclid=(.*?)(&.*|)$/, :gclid], 
            [:get, /[&|?]utm_term=(.*?)(&.*|)$/, :utm_term], 
            [:get, /[&|?]utm_source=(.*?)(&.*|)$/, :utm_source], 
            [:get, /[&|?]utm_medium=(.*?)(&.*|)$/, :utm_medium], 
            [:get, /[&|?]utm_content=(.*?)(&.*|)$/, :utm_content], 
            [:get, /[&|?]utm_campaign=(.*?)(&.*|)$/, :utm_campaign]
          ]
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

      def user_agent_robots
        # The http request User-Agent is matched against the regexps in this Array.
        # A Visit::Trait is created if there's a match.
        # Also see Visit::UserAgentRobotQuery.
        # Handy for distinguishing (some) robot traffic from human traffic.

        @user_agent_robots ||= 
        [
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
          /PaperLiBot/i
        ]
      end

      def async_library
        unless Async::LIBS_SUPPORTED.include?(@async_library)
          @async_library = nil
        else
          @async_library
        end
      end

      def async_queue_name
        @async_queue_name ||= "visit-data-collection"
      end

      def notify(e)
        if @notifier.present? && (@notifier.is_a? Proc)
          @notifier.call(e)
        else
          Rails.logger.error "ERROR IN VISIT GEM: #{e.to_s}"
        end
      end
      
    end
  end
end
