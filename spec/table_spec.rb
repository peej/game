require "#{File.dirname(__FILE__)}/../card.rb"
require "#{File.dirname(__FILE__)}/../table.rb"
require "#{File.dirname(__FILE__)}/../token.rb"

describe Table do

  before :each do
    @table = Table.new
  end

  it "should have the goal card on the table" do
    expect(@table.card(0, 0)).to be_a(Goal)
  end
  
  it "can have cards placed upon it" do
    @table.placeCard Card.new(:distributor_road, :access_road, :distributor_road, :access_road), [1, 0]
  end

  it "can not have two cards placed into the same location" do
    @table.placeCard Card.new(:distributor_road, :access_road, :distributor_road, :access_road), [1, 0]
    lambda { @table.placeCard Card.new(:distributor_road, :access_road, :distributor_road, :access_road), [1, 0] }.should raise_error(Table::PositionNotEmptyException)
  end

  it "only allows a card to be placed next to an existing card" do
    lambda { @table.placeCard Card.new(:distributor_road, :access_road, :distributor_road, :access_road), [2, 0] }.should raise_error(Table::NotNextToAnotherCardException)
  end

  it "only allows a card to be placed if it fits the surrounding cards" do
    @table.placeCard Card.new(:through_road, :through_road, :distributor_road, :through_road), [0, -1] # north
    @table.placeCard Card.new(:through_road, :through_road, :through_road, :access_road), [1, 0] # east
    @table.placeCard Card.new(:distributor_road, :through_road, :through_road, :through_road), [0, 1] # south
    @table.placeCard Card.new(:through_road, :access_road, :through_road, :through_road), [-1, 0] # west
    lambda { @table.placeCard Card.new(:access_road, :access_road, :access_road, :access_road), [0, -2] }.should raise_error(Table::CardDoesNotFitException)
    lambda { @table.placeCard Card.new(:access_road, :access_road, :access_road, :access_road), [2, 0] }.should raise_error(Table::CardDoesNotFitException)
    lambda { @table.placeCard Card.new(:access_road, :access_road, :access_road, :access_road), [0, 2] }.should raise_error(Table::CardDoesNotFitException)
    lambda { @table.placeCard Card.new(:access_road, :access_road, :access_road, :access_road), [-2, 0] }.should raise_error(Table::CardDoesNotFitException)
  end

  it "allows a token to be placed in the corner of a card" do
    card = Card.new(:distributor_road, :through_road, :through_road, :through_road)
    @table.placeCard(card, [0, 1])
    @table.placeToken(Token.new(), card, :north_west)
    expect(card.token?).to eq true
    expect(card.token?(:north_west)).to eq true
  end

  it "disallows a token to be placed into a region that already has a token" do
    card1 = Card.new(:distributor_road, :distributor_road, :distributor_road, :distributor_road)
    card2 = Card.new(:through_road, :distributor_road, :through_road, :distributor_road)
    card3 = Card.new(:through_road, :access_road, :through_road, :access_road)
    card4 = Card.new(:through_road, :distributor_road, :through_road, :distributor_road)

    @table.placeCard(card1, [0, 1])
    @table.placeCard(card2, [1, 1])
    @table.placeCard(card3, [1, 0])
    @table.placeCard(card4, [1, -1])

    @table.placeToken(Token.new(), card1, :north_east)

    lambda { @table.placeToken(Token.new(), card2, :north_west) }.should raise_error(Table::RegionAlreadyContainsTokenException)

  end

end