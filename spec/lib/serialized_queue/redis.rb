require 'spec_helper'

describe Visit::SerializedList::Redis do
  let(:list) { Visit::SerializedList.new('test:serialized_list') }

  before { list.clear }

  it "allows push and retrieval of serialized data" do
    list.push({a: 1})

    expect(list.values).to eq([{a: 1}])
  end

  it "pushs list data to a list" do
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
end


