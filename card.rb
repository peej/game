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

  TypeMatches = {
    through_road: [:through_road],
    distributor_road: [:distributor_road],
    access_road: [:access_road, :access_road_no_veh, :access_road_ped_only],
    access_road_no_veh: [:access_road, :access_road_no_veh, :access_road_ped_only],
    access_road_ped_only: [:access_road, :access_road_no_veh, :access_road_ped_only]
  }

  TransitAllowed = {
    pedestrian: [:through_road, :distributor_road, :access_road, :access_road_no_veh, :access_road_ped_only],
    bicycle: [:through_road, :distributor_road, :access_road, :access_road_no_veh],
    car: [:through_road, :distributor_road, :access_road]
  }

  def initialize(*args)
    @token = nil

    if args.size == 1
      @north, val = Types.rassoc(args[0][0])
      @east, val = Types.rassoc(args[0][1])
      @south, val = Types.rassoc(args[0][2])
      @west, val = Types.rassoc(args[0][3])
    elsif args.size == 4
      @north = args[0] || :through_road
      @east = args[1] || :through_road
      @south = args[2] || :through_road
      @west = args[3] || :through_road
    else
      raise Exception.new("Provide either a type code or parameters for north, east, south and west")
    end
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

  def can_travel(direction, transit_type)
    case direction
    when :north
      TransitAllowed[transit_type].include? @north
    when :east
      TransitAllowed[transit_type].include? @east
    when :south
      TransitAllowed[transit_type].include? @south
    when :west
      TransitAllowed[transit_type].include? @west
    end
  end

  def fits_against?(card, direction)
    case direction
    when :north
      TypeMatches[@north].include? card.south
    when :east
      TypeMatches[@east].include? card.west
    when :south
      TypeMatches[@south].include? card.north
    when :west
      TypeMatches[@west].include? card.east
    end
  end

  def to_s
    #output = "+---+\n"
    #output += "| #{Types[@north]} |\n"
    #output += "|#{Types[@west]}+#{Types[@east]}|\n"
    #output += "| #{Types[@south]} |\n"
    #output += "+---+"
    #output
    type
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