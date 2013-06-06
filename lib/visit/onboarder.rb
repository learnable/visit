module Visit
  class Onboarder
    def self.ignorable?(path)
      ret = nil

      Configurable.ignorable.each do |re|
        ret = path =~ re
        break if ret
      end

      !ret.nil?
    end
  end
end
