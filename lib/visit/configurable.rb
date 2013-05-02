module Visit
  class Configurable
    class << self
      attr_accessor :notifier, :current_user_alias, 
        :ignorable, :labels_match_first, :labels_match_all, 
        :user_agent_robots, :async_library, :async_queue_name
      
      def configure
        yield(self)
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
          [ :gclid, :utm_term, :utm_source, :utm_medium, :utm_content, :utm_campaign ].map do |k|
            [ :get, Regexp.new("[&|?]#{k.to_s}=(.*?)(&.*|)$"), k ]
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
        @async_queue_name ||= :visit
      end

      def create(obj)
        case async_library
        when :resque
          Resque.enqueue_to(async_queue_name, Async::ArrivalWorker, obj)
        when :sidekiq
          arrival_worker = Async::ArrivalWorker
          arrival_worker.send(:include, Sidekiq::Worker)
          Sidekiq::Client.enqueue_to(async_queue_name, arrival_worker, obj)
        else
          Arrival.create(obj)
        end
      end

      def notify(e)
        if @notifier.present? && (@notifier.is_a? Proc)
          @notifier.call(e)
        else
          Rails.logger.error "ERROR IN VISIT GEM: #{e.to_s}"
        end
      end

      private

      def async_mode?
        async_library.present?
      end

    end
  end
end
