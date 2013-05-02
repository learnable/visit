module Visit
  module Async
    LIBS_SUPPORTED = [:resque, :sidekiq]

    class ArrivalWorker
      def self.perform(obj)
        a = Visit::Arrival.create(obj)
        p a.errors.full_messages
      end
    end
  end
end
