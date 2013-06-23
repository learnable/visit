module Visit
  module SerializedQueue::HasInstances
    extend ActiveSupport::Concern

    module ClassMethods
      def instances(key)
        @instances ||= {}
        @instances[key] ||= self.new
      end

      def clone_to_instance(queue, new_key)
        @instances[new_key] = queue.clone
      end
    end
  end
end
