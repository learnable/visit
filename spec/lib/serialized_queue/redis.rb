require 'spec_helper'

describe Visit::SerializedQueue::Redis do
  let(:list) { Visit::SerializedQueue::Redis.new('test_serialized_queue') }

  before { list.clear }

  it "supports push of one item, and retrieval thereof" do
    list.push({a: 1})

    expect(list.values).to eq([{a: 1}])
  end

  it "supports push of two items, and retrieval thereof" do
    list.push({a: 1})
    list.push({b: 2})

    expect(list.values).to eq([{a: 1}, {b: 2}])
  end

  it "has a length" do
    list.push({a: 1})
    expect(list.length).to eq(1)

    list.push({b: 2})
    expect(list.length).to eq(2)
  end

  it "can be cleared" do
    list.push({a: 1})
    expect(list.length).to eq(1)

    list.clear

    expect(list.values).to eq([])
    expect(list.length).to eq(0)
  end

  it "has a pipelined push+length operation" do
    length = list.pipelined_push_and_return_length({a: 1})
    expect(length).to eq(1)

    length = list.pipelined_push_and_return_length({b: 2})
    expect(length).to eq(2)
  end

  it "has a pipelined pop+clear operation" do
    list.push ({a: 1})
    list.push ({b: 2})
    list.push ({c: 3})

    expect(list.pipelined_pop_and_clear(3)).to eq([{a: 1},{b: 2},{c: 3}])
    expect(list.length).to eq(0)
  end
  end
end


