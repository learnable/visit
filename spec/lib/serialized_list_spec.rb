require 'spec_helper'

describe Visit::SerializedList do
  let(:list) { Visit::SerializedList.new('test:serialized_list') }

  before { list.clear }

  it "allows insert and retrieval of serialized data" do
    list.insert({a: 1})

    expect(list.values).to eq([{a: 1}])
  end

  it "appends list data to a list" do
    list.insert({a: 1})
    list.insert({b: 2})

    expect(list.values).to eq([{a: 1}, {b: 2}])
  end

  it "has a length" do
    list.insert({a: 1})
    expect(list.length).to eq(1)

    list.insert({b: 2})
    expect(list.length).to eq(2)
  end

  it "can be cleared" do
    list.insert({a: 1})
    expect(list.length).to eq(1)

    list.clear

    expect(list.values).to eq([])
    expect(list.length).to eq(0)
  end

end


