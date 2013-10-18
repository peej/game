class Card
  
  attr_reader :north, :east, :south, :west
  attr_accessor :token

  Types = {
    through_road: "t",
    distributor_road: "d",
    access_road: "a",
    access_road_no_veh: "b",
    access_road_ped_only: "c"
  }

  def initialize(north = :through_road, east = :through_road, south = :through_road, west = :through_road)
    @north = north
    @east = east
    @south = south
    @west = west
    @token = nil
  end

  def type
    symbol = ""

    [@north, @east, @south, @west].each do |direction|
      Types.each do |type, letter|
        symbol += letter if type == direction
      end
    end

    :"#{symbol}"
  end

  def rotate(direction)
    if direction == :clockwise
      old_north = @north
      @north = @west
      @west = @south
      @south = @east
      @east = old_north
    elsif direction == :anti_clockwise
      old_north = @north
      @north = @east
      @east = @south
      @south = @west
      @west = old_north
    elsif direction == :one_eighty
      @north, @south = @south, @north
      @east, @west = @west, @east
    else
      raise Exception.new("Invalid direction to rotate card")
    end
  end

  def token?(corner = nil)
    return !!@token if corner == nil
    @token.corner == corner
  end

  def block_corner?(side)
    side_type = instance_variable_get("@#{side}")
    side_type == :through_road || side_type == :distributor_road
  end

  def to_s
    output = "+---+\n"
    output += "| #{Types[@north]} |\n"
    output += "|#{Types[@west]}+#{Types[@east]}|\n"
    output += "| #{Types[@south]} |\n"
    output += "+---+"
    output
  end

end

class Goal < Card

  def initialize
    @north = :distributor_road
    @east = :access_road
    @south = :distributor_road
    @west = :access_road
  end

end