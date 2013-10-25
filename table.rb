class Table

  PositionNotEmptyException = Class.new(StandardError)
  PositionEmptyException = Class.new(StandardError)
  NotNextToAnotherCardException = Class.new(StandardError)
  CardDoesNotFitException = Class.new(StandardError)
  RegionAlreadyContainsTokenException = Class.new(StandardError)
  
  # size of the table, will be ((SIZE * 2) + SIZE) ^ 2 in size (-SIZE to +SIZE centered around zero)
  SIZE = 10

  def initialize
    @positions = [[nil]]
    @positions[SIZE] = [nil]
    @positions[SIZE][SIZE] = Goal.new
  end

  def get_card(x, y)
    @positions[SIZE + x] = [] if @positions[SIZE + x] == nil
    @positions[SIZE + x][SIZE + y]
  end

  def set_card(x, y, card)
    @positions[SIZE + x] = [] if @positions[SIZE + x] == nil
    @positions[SIZE + x][SIZE + y] = card
  end

  def to_s
    @positions.each do |row|

    end
  end

  def place_card(card, position)

    if card.class.name != "Card"
      card = Card.new(card)
    end
    
    x, y = position[0], position[1]

    if get_card(x, y) != nil
      raise PositionNotEmptyException.new("Can not place card over existing card")
    end

    card_to_north = get_card(x, y - 1)
    card_to_east = get_card(x + 1, y)
    card_to_south = get_card(x, y + 1)
    card_to_west = get_card(x - 1, y)

    if card_to_north == nil && card_to_east == nil && card_to_south == nil && card_to_west == nil
      raise NotNextToAnotherCardException.new("Card must be placed next to an existing card")
    end

    if card_to_north != nil && !card_to_north.fits_against?(card, :south)
      raise CardDoesNotFitException.new("Card #{card} does not fit next to card #{card_to_north} to the north")
    end
    if card_to_east != nil && !card_to_east.fits_against?(card, :west)
      raise CardDoesNotFitException.new("Card #{card} does not fit next to card #{card_to_east} to the east")
    end
    if card_to_south != nil && !card_to_south.fits_against?(card, :north)
      raise CardDoesNotFitException.new("Card #{card} does not fit next to card #{card_to_south} to the south")
    end
    if card_to_west != nil && !card_to_west.fits_against?(card, :east)
      raise CardDoesNotFitException.new("Card #{card} does not fit next to card #{card_to_west} to the west")
    end

    set_card x, y, card

  end

  def get_position_of_card(card)
    index_x = @positions.index { |arr| arr.include? card if arr.class == Array }
    if index_x == nil
      raise Exception.new("Card not found on table")
    end
    index_y = @positions[index_x].index(card)
    return index_x, index_y
  end

  def region(card, corner)
    index_x, index_y = get_position_of_card(card)
    
    #print "\n", index_x, ",", index_y, ":", corner, "\n"

    [:clockwise, :anti_clockwise].each do |direction|
      next_card = card
      next_val = {
        x: index_x,
        y: index_y,
        corner: corner
      }
      case direction
      when :clockwise
        actions = {
          north_east: [:north, [:y, -1, :south_east], [:x, -1]],
          north_west: [:west, [:x, -1, :north_east], [:x, -1]],
          south_west: [:south, [:y, 1, :north_west], [:x, 1]],
          south_east: [:east, [:x, 1, :south_west], [:y, -1]]
        }
      when :anti_clockwise
        actions = {
          north_east: [:east, [:x, 1, :north_west], [:y, 1]],
          north_west: [:north, [:y, -1, :south_west], [:x, 1]],
          south_west: [:west, [:x, -1, :south_east], [:y, -1]],
          south_east: [:north, [:y, 1, :north_east], [:x, -1]]
        }
      end

      begin
        if yield next_card, next_val[:corner]
          break
        end
        
        bc, yes, no = actions[next_val[:corner]]

        if next_card == nil
          break
        elsif next_card.block_corner?(bc)
          next_val[yes[0]] += yes[1]
          next_val[:corner] = yes[2]
        else
          next_val[no[0]] += no[1]
        end

        next_card = @positions[next_val[:x]][next_val[:y]]

      end until next_card == nil || next_card == card

      break if next_card == card

    end
  end

  def place_token(token, card, corner)
    region_contains_token = false
    region(card, corner) do |next_card, next_corner = nil|
      begin
        if (next_corner == nil && next_card.token)
          region_contains_token = true
        elsif next_card.token.corner == next_corner
          region_contains_token = true
        end
      rescue NoMethodError
        false
      end
    end

    if region_contains_token
      raise RegionAlreadyContainsTokenException.new("The region already has a token in it")
    end

    token.corner = corner
    card.token = token
  end

end