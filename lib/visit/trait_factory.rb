module Visit
  class TraitFactory
    def initialize
      @tuplet_factory = TupletFactory.new
    end

    def self.delete_all
      Trait.delete_all
      TraitValue.delete_all
    end

    def self.recreate_all
      Configurable.cache.clear
      delete_all
      self.new.run
    end

    # create Traits and TraitValues in batches
    #
    def run
      Event.
        newer_than_visit_trait(Trait.last).
        includes(:visit_source_values_url, :visit_source_values_user_agent).
        find_in_batches do |a_ve|

        tuplets = create_traits_for_visit_events a_ve

        yield get_activity(tuplets) if block_given?
      end
    end

    def create_traits_for_visit_events(a_ve)
      tuplets = @tuplet_factory.tuplets_from_ve_batch a_ve

      if !tuplets.empty?
        # batch insert like this is 10x faster than create!
        # which really matters when recreating all the traits from scratch
        # TODO: validate the visit_traits just inserted
        #
        ActiveRecord::Base.connection.execute \
          "INSERT INTO visit_traits (k_id, v_id, visit_event_id, created_at) values" +
          tuplets.map { |t| t.to_s }.join(',')
      end
      tuplets
    end

    private

    def get_activity(tuplets)
      {}.tap do |activity|
        tuplets.each do |t|
          activity[t.ve_id] = {} if !activity.has_key?(t.ve_id)
          activity[t.ve_id][t.k] = t.v
        end
      end
    end
  end

  class TraitFactory::Tuplet < Struct.new(:k_id, :v_id, :k, :v, :ve_id, :timestamp)
    def to_s
      "(#{k_id}, #{v_id}, #{ve_id}, '#{timestamp}')"
    end
  end

  class TraitFactory::TupletFactory
    def tuplets_from_ve_batch(a_ve)
      a_ve.each.flat_map do |ve|
        tuplets_from_ve ve
      end
    end

    private

    def tuplets_from_ve(ve)
      Event::Traits.new(ve).to_h.each.map do |k,v|
        if v.nil? || v.empty?
          nil
        else
          k_id = get_trait_value_id k
          v_id = get_trait_value_id v

          TraitFactory::Tuplet.new k_id, v_id, k, v, ve.id, Time.now
        end
      end.select{ |tuplet| !tuplet.nil? }
    end

    def get_trait_value_id(str)
      TraitValue.get_id_from_optimistic_find_or_create_by_v(str)
    end
  end
end
