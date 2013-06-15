require 'spec_helper'

describe Visit::SerializedList::Redis do
  let(:list) { Visit::SerializedList.new('test:serialized_list') }

  before { list.clear }

  it "allows append and retrieval of serialized data" do
    list.append({a: 1})

    expect(list.values).to eq([{a: 1}])
  end

  it "appends list data to a list" do
    list.append({a: 1})
    list.append({b: 2})

    expect(list.values).to eq([{a: 1}, {b: 2}])
  end

  it "has a length" do
    list.append({a: 1})
    expect(list.length).to eq(1)

    list.append({b: 2})
    expect(list.length).to eq(2)
  end

  it "can be cleared" do
    list.append({a: 1})
    expect(list.length).to eq(1)

    list.clear

    expect(list.values).to eq([])
    expect(list.length).to eq(0)
  end

  it "has a pipelined append+length operation" do
    length = list.pipelined_append_and_return_length({a: 1})
    expect(length).to eq(1)

    length = list.pipelined_append_and_return_length({b: 2})
    expect(length).to eq(2)
  end
end


