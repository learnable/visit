require 'spec_helper'

describe Visit::SerializedQueue::Redis do
  let(:list) { Visit::SerializedQueue::Redis.new('test_serialized_queue') }

  before { list.clear }

  it "supports rpush and lpop of one item" do
    list.push({a: 1})

    expect(list.lpop).to eq({a: 1})
  end

  it "supports rpush and lpop of two items" do
    list.rpush({a: 1})
    list.rpush({b: 2})

    expect(list.lpop).to eq({a: 1})
    expect(list.lpop).to eq({b: 2})
  end

  it "has a length" do
    list.rpush({a: 1})
    expect(list.length).to eq(1)

    list.rpush({b: 2})
    expect(list.length).to eq(2)
  end

  it "can be cleared" do
    list.rpush({a: 1})
    expect(list.length).to eq(1)

    list.clear

    expect(list.length).to eq(0)
  end

  it "has a pipelined rpush+length operation" do
    length = list.pipelined_rpush_and_return_length({a: 1})
    expect(length).to eq(1)

    length = list.pipelined_rpush_and_return_length({b: 2})
    expect(length).to eq(2)
  end

  it "has a pipelined lpop+clear operation" do
    list.rpush ({a: 1})
    list.rpush ({b: 2})
    list.rpush ({c: 3})

    expect(list.pipelined_lpop_and_clear(3)).to eq([{a: 1},{b: 2},{c: 3}])
    expect(list.length).to eq(0)
  end
  end
end


