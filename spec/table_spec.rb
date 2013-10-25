require "#{File.dirname(__FILE__)}/../card.rb"
require "#{File.dirname(__FILE__)}/../table.rb"
require "#{File.dirname(__FILE__)}/../token.rb"

describe Table do

  before :each do
    @table = Table.new

    cards = [
      [:adad, :tdtd, :dddd, :addd, :adad, :bdad, :adad, :tbtd, :aaaa],
      [:btbt, :tttt, :dtbt, :dtdt, :btbt, :btdt, :btbt, :tttt, :btbt],
      [:aaaa, :tbtb, :aaaa, :dbdb, :abab, :ddda, :adad, :tbtd, :aaaa],
      [:adad, :tbtd, :aaaa, nil, :aaaa, :dcdc, :aaaa, :tbtb, :adda],
      [:baba, :tbtb, :abab, :dbda, :aaaa, :dada, :aaaa, :tbtb, :dada],
      [:btbt, :tttt, :btdt, :dtbt, :btbt, :dtdt, :btbt, :tttt, :dtbt],
      [:adad, :tdtd, :dddd, :adbd, :adad, :ddad, :adad, :tdtd, :adad]
    ]

    4.upto(8) { |foo| @table.place_card cards[3][foo], [foo - 3, 0]}
    8.downto(0) { |foo| @table.place_card cards[4][foo], [foo - 3, 1]}
    8.downto(0) { |foo| @table.place_card cards[5][foo], [foo - 3, 2]}
    8.downto(0) { |foo| @table.place_card cards[6][foo], [foo - 3, 3]}

    2.downto(0) { |foo| @table.place_card cards[3][foo], [foo - 3, 0]}
    0.upto(8) { |foo| @table.place_card cards[2][foo], [foo - 3, -1]}
    0.upto(8) { |foo| @table.place_card cards[1][foo], [foo - 3, -2]}
    0.upto(8) { |foo| @table.place_card cards[0][foo], [foo - 3, -3]}

    @table.place_token(Token.new(), @table.get_card(0, -1), :south_east)
    
  end

  it "should have the goal card on the table" do
    expect(@table.get_card(0, 0)).to be_a(Goal)
  end

  it "can have cards placed upon it" do
    @table.place_card :adad, [6, 0]
  end

  it "can not have two cards placed into the same location" do
    lambda { @table.place_card :dada, [1, 0] }.should raise_error(Table::PositionNotEmptyException)
  end

  it "only allows a card to be placed next to an existing card" do
    lambda { @table.place_card :dada, [7, 0] }.should raise_error(Table::NotNextToAnotherCardException)
  end

  it "only allows a card to be placed if it fits the surrounding cards" do
    lambda { @table.place_card :aaaa, [6, 0] }.should raise_error(Table::CardDoesNotFitException)
    lambda { @table.place_card :aaaa, [4, -4] }.should raise_error(Table::CardDoesNotFitException)
    lambda { @table.place_card :aaaa, [-4, -2] }.should raise_error(Table::CardDoesNotFitException)
    lambda { @table.place_card :aaaa, [-1, 4] }.should raise_error(Table::CardDoesNotFitException)
  end

  it "allows a token to be placed in the corner of a card" do
    card = @table.get_card 0, 1
    @table.place_token(Token.new(), card, :north_west)
    expect(card.token?).to eq true
    expect(card.token?(:north_west)).to eq true
  end

  it "disallows a token to be placed into a closed region that already has a token" do
    card1 = @table.get_card 2, 0
    @table.place_token(Token.new(), card1, :north_east)

    card2 = @table.get_card 4, 1
    lambda { @table.place_token(Token.new(), card2, :south_west) }.should raise_error(Table::RegionAlreadyContainsTokenException)
  end

  it "disallows a token to be placed into an open region that already has a token" do
    card1 = @table.get_card -2, 0
    @table.place_token(Token.new(), card1, :north_west)

    card2 = @table.get_card -3, -1
    lambda { @table.place_token(Token.new(), card2, :south_west) }.should raise_error(Table::RegionAlreadyContainsTokenException)
  end

=begin
  it "disallows a token to be placed into a region that has a token in an internal card" do
    card1 = @table.get_card 3, 0
    @table.place_token(Token.new(), card1, :north_east)

    card2 = @table.get_card 4, 1
    lambda { @table.place_token(Token.new(), card2, :south_west) }.should raise_error(Table::RegionAlreadyContainsTokenException)
  end
=end


  it "can find a path from a token to the goal" do
    card = @table.get_card -3, 1
    token = Token.new()
    @table.place_token(token, card, :north_west)

    #@table.is_valid_route? token
  end

end