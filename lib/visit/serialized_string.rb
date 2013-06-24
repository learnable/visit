module Visit
  class SerializedString < Array
    def initialize(data)
      @data = data
    end

    def encode
      [@data]
    end

    def decode
      @data.nil? ? "" : @data.first
    end
  end
end

