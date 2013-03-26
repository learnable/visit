
shared_context "gem_config" do
  # Use function as rspec warns against using 'let' variables in a
  # before :all block
  def labels
    [{
      :http_method  => :get,
      :re           => /^\/articles$/,
      :label        => :articles_index,
      :has_sublabel => false
    },
      {
      :http_method  => :get,
      :re           => /^\/articles\/\d/,
      :label        => :article,
      :has_sublabel => false
    }
    ]
  end

  # Configure the gem
  before :all do
    Visit::Configurable.instance_exec(labels) do |_labels|
      @_labels = _labels
      def labels
        @_labels
      end
      def ignorable
        [
          /\/courses\/blah.js/,
          /\/system\/blah/,
        ]
      end
    end
  end

end
