module Visit
  class TraitFactory
    def initialize
      @cache = {}
    end

    def self.delete_all
      Visit::Trait.delete_all
      Visit::TraitValue.delete_all
    end

    def self.recreate_all
      delete_all
      self.new.create
    end

    # create Traits and TraitValues in batches
    #
    def run
      Visit::Event.newer_than_visit_trait(Visit::Trait.last).find_in_batches do |a_ve|
        activity = {} if block_given?
        a_insert_values = []

        a_ve.each do |ve|
          activity[ve.id] = {} if block_given?

          get_insert_values ve do |k, k_id, v, v_id|
            a_insert_values << "(#{k_id}, #{v_id}, #{ve.id}, '#{Time.now}')"
            activity[ve.id][k] = v if block_given?
          end
        end

        if !a_insert_values.empty?
          # batch insert like this is 10x faster than create!
          # but it wouldn't hurt to now validate the visit_traits just inserted
          #
          ActiveRecord::Base.connection.execute \
            "INSERT INTO visit_traits (k_id, v_id, visit_event_id, created_at) values" +
            a_insert_values.join(',')
        end

        yield activity if block_given?
      end
    end

    private

    def get_insert_values ve
      Visit::Event::Traits.new(ve).to_h.each do |k,v|
        if !v.nil? && !v.empty?
          k_id = get_trait_value_id k
          v_id = get_trait_value_id v

          yield k, k_id, v, v_id
        end
      end
    end

    def get_trait_value_id str
      if @cache.has_key?(str)
        @cache[str]
      else
        @cache[str] = Visit::TraitValue.where(:v => str).first_or_create(:v => str).id
      end
    end

  end
end
