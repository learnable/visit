module Visit
  module Async
    LIBS_SUPPORTED = [:resque, :sidekiq]

    class ArrivalWorker
      def self.perform(visit_event_hash)
        Visit::Arrival.create_if_interesting(visit_event_hash)
      end
    end
  end
end
