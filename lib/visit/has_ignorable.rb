module Visit
  module HasIgnorable
    def ignorable?
      mi = self.respond_to?(:must_insert) ? must_insert : false

      !mi && Onboarder.ignorable?(path)
    end
  end
end
