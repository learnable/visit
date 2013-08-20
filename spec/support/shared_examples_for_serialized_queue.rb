shared_examples "a SerializedQueue" do |new_queue|

  let (:queue) { new_queue.call(:test_queue) }

  before { queue.clear }
  after { queue.clear }

  it "supports rpush and lpop of a Hash" do
    queue.rpush({"a" => 1})

    expect(queue.lpop).to eq({"a" => 1})
  end

  it "supports rpush and lpop of an Array" do
    queue.rpush([1,2])

    expect(queue.lpop).to eq([1,2])
  end

  it "raises an exception on rpush of a string" do
    expect { queue.rpush("fred") }.to raise_error(RuntimeError)
  end

  it "supports rpush and lpop of a SerializedString" do
    queue.rpush Visit::SerializedString.new("fred").encode

    expect(Visit::SerializedString.new(queue.lpop).decode).to eq("fred")
  end

  it "supports rpush and lpop of two items" do
    queue.rpush({"a" => 1})
    queue.rpush({"b" => 2})

    expect(queue.lpop).to eq({"a" => 1})
    expect(queue.lpop).to eq({"b" => 2})
  end

  it "#lpop on an empty queue returns nil" do
    expect(queue.lpop).to eq(nil)
  end

  it "has a length" do
    queue.rpush({"a" => 1})
    expect(queue.length).to eq(1)

    queue.rpush({"b" => 2})
    expect(queue.length).to eq(2)
  end

  it "can be cleared" do
    queue.rpush({"a" => 1})
    expect(queue.length).to eq(1)

    queue.clear

    expect(queue.length).to eq(0)
  end

  it "has a pipelined rpush+length operation" do
    length = queue.pipelined_rpush_and_return_length({"a" => 1})
    expect(length).to eq(1)

    length = queue.pipelined_rpush_and_return_length({"b" => 2})
    expect(length).to eq(2)
  end

  it "has values" do
    serialized_string = Visit::SerializedString.new("fred").encode

    queue.rpush ({"a" => 1})
    queue.rpush ([1,2,3])
    queue.rpush serialized_string

    expect(queue.values).to eq([{"a" => 1},[1,2,3],serialized_string])
  end

  context "the renamenx_to_random_key operation" do
    after { new_queue.call(@key).clear }

    it "renames the key" do
      queue.rpush ({"a" => 1})

      @key = queue.renamenx_to_random_key

      @key.should_not be_nil

      q2 = new_queue.call @key

      expect(q2.values).to eq([{"a" => 1}])
    end
  end
end
