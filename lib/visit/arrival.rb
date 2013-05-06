module Visit
  class Arrival
    class << self

      def create_with_async(visit_event_hash)
        case Configurable.async_library
        when :resque
          Resque.enqueue_to(Configurable.async_queue_name, Async::ArrivalWorker, visit_event_hash)
        when :sidekiq
          arrival_worker = Async::ArrivalWorker
          arrival_worker.send(:include, Sidekiq::Worker)
          Sidekiq::Client.enqueue_to(Configurable.async_queue_name, arrival_worker, visit_event_hash)
        else
          create_if_interesting(visit_event_hash)
        end
      end      

      def create_if_interesting(visit_event_hash)
        visit_event_hash.symbolize_keys! # In case it's coming back unmarshalled from Redis
        unless Visit::Event.ignore?(visit_event_hash[:url])
          begin
            visit_event = create(visit_event_hash)
          rescue
            Visit::Configurable.notify $!
          end
        end
      end

      private

      def create(visit_event_hash)
        visit_event = create_visit(visit_event_hash)
        Visit::TraitFactory.new.create_traits_for_visit_events([visit_event])
        visit_event
      end      

      def create_visit(visit_event_hash)
        visit_event = Visit::Event.new \
          vid:       visit_event_hash[:vid],
          user_id:   visit_event_hash[:user_id],
          remote_ip: visit_event_hash[:remote_ip]

        visit_event.url_id        = Visit::SourceValue.optimistic_find_or_create_by_v(visit_event_hash[:url]).id
        visit_event.user_agent_id = Visit::SourceValue.optimistic_find_or_create_by_v(visit_event_hash[:user_agent]).id
        visit_event.referer_id    = Visit::SourceValue.optimistic_find_or_create_by_v(visit_event_hash[:referer]).id
        visit_event.http_method   = visit_event_hash[:http_method]
        visit_event.save!

        # Visit::Manage::log "Visit::Arrival::create_visit saved ve: #{ve.to_yaml}"

        visit_event_hash[:cookies].each do |k,v|
          visit_source = Visit::Source.new
          visit_source.visit_event_id = visit_event.id
          visit_source.k_id = Visit::SourceValue.optimistic_find_or_create_by_v(k).id
          visit_source.v_id = Visit::SourceValue.optimistic_find_or_create_by_v(v).id
          visit_source.save!
        end

        visit_event
      end
    end
  end
end
