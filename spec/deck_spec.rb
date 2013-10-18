require "#{File.dirname(__FILE__)}/../deck.rb"

describe Deck do
  
  before :each do
    @deck = Deck.new
  end

  it "has 92 cards" do
    expect(@deck.length).to eq 92
  end

  it "has cards of the correct types" do
    expect((@deck.select {|i| i.type == :tttt}).length).to eq 4
    expect((@deck.select {|i| i.type == :tdtd}).length).to eq 8
    expect((@deck.select {|i| i.type == :tbtb}).length).to eq 12
    expect((@deck.select {|i| i.type == :tdtb}).length).to eq 8

    expect((@deck.select {|i| i.type == :dddd}).length).to eq 4
    expect((@deck.select {|i| i.type == :dada}).length).to eq 12
    expect((@deck.select {|i| i.type == :dbdb}).length).to eq 4
    expect((@deck.select {|i| i.type == :dadb}).length).to eq 4
    expect((@deck.select {|i| i.type == :ddda}).length).to eq 4
    expect((@deck.select {|i| i.type == :dddb}).length).to eq 4
    expect((@deck.select {|i| i.type == :ddaa}).length).to eq 4
    expect((@deck.select {|i| i.type == :daaa}).length).to eq 4

    expect((@deck.select {|i| i.type == :aaaa}).length).to eq 12
    expect((@deck.select {|i| i.type == :abab}).length).to eq 4
    expect((@deck.select {|i| i.type == :acac}).length).to eq 4
  end

  it "can be shuffled" do
    shuffled_deck = @deck.shuffle
    shuffled_deck2 = @deck.shuffle
    expect(shuffled_deck == shuffled_deck2).to be(false)
  end

  it "can have the top card drawn" do
    expect(@deck.draw).to be_a(Card)
  end

end