module Visit
  class TraitFactory
    def initialize
      @tuplet_factory = TupletFactory.new
    end

    def self.delete_all
      Visit::Trait.delete_all
      Visit::TraitValue.delete_all
    end

    def self.recreate_all
      delete_all
      self.new.run
    end

    # create Traits and TraitValues in batches
    #
    def run
      Visit::Event.
        newer_than_visit_trait(Visit::Trait.last).
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
end

class Visit::TraitFactory::Tuplet < Struct.new(:k_id, :v_id, :k, :v, :ve_id, :timestamp)
  def to_s
    "(#{k_id}, #{v_id}, #{ve_id}, '#{timestamp}')"
  end
end

class Visit::TraitFactory::TupletFactory
  def initialize
    @cache = {}
  end

  def tuplets_from_ve_batch(a_ve)
    a_ve.each.flat_map do |ve|
      tuplets_from_ve ve
    end
  end

  private

  def tuplets_from_ve(ve)
    Visit::Event::Traits.new(ve).to_h.each.map do |k,v|
      if v.nil? || v.empty?
        nil
      else
        k_id = get_trait_value_id k
        v_id = get_trait_value_id v

        Visit::TraitFactory::Tuplet.new k_id, v_id, k, v, ve.id, Time.now
      end
    end.select{ |tuplet| !tuplet.nil? }
  end

  def get_trait_value_id(str)
    if @cache.has_key?(str)
      @cache[str]
    else
      @cache[str] = Visit::TraitValue.where(:v => str).first_or_create(:v => str).id
    end
  end
end
