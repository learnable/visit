shared_examples "a SerializedQueue" do

  before { queue.clear }
  after { queue.clear }

  it "supports rpush and lpop of one item" do
    queue.rpush({a: 1})

    expect(queue.lpop).to eq({a: 1})
  end

  it "supports rpush and lpop of two items" do
    queue.rpush({a: 1})
    queue.rpush({b: 2})

    expect(queue.lpop).to eq({a: 1})
    expect(queue.lpop).to eq({b: 2})
  end

  it "has a length" do
    queue.rpush({a: 1})
    expect(queue.length).to eq(1)

    queue.rpush({b: 2})
    expect(queue.length).to eq(2)
  end

  it "can be cleared" do
    queue.rpush({a: 1})
    expect(queue.length).to eq(1)

    queue.clear

    expect(queue.length).to eq(0)
  end

  it "has a pipelined rpush+length operation" do
    length = queue.pipelined_rpush_and_return_length({a: 1})
    expect(length).to eq(1)

    length = queue.pipelined_rpush_and_return_length({b: 2})
    expect(length).to eq(2)
  end

  it "has a pipelined lpop+clear operation" do
    queue.rpush ({a: 1})
    queue.rpush ({b: 2})
    queue.rpush ({c: 3})

    expect(queue.pipelined_lpop_and_clear(3)).to eq([{a: 1},{b: 2},{c: 3}])
    expect(queue.length).to eq(0)
  end
end
