require 'visit/deduper.rb'

module Visit
  class ValueDeduper < Deduper
    # TODO remove me once flippa has s/ValueDeduper/Deduper/

    def self.run
      DeDuper.new.run
    end
  end
end
