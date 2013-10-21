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

  def card(x, y)
    @positions[SIZE + x] = [] if @positions[SIZE + x] == nil
    @positions[SIZE + x][SIZE + y] = [] if @positions[SIZE + x][SIZE + y] == nil
    @positions[SIZE + x][SIZE + y]
  end

  def to_s
    @positions.each do |row|

    end
  end

  def placeCard(card, position)

    if card.class.name != "Card"
      card = Card.new(card)
    end
    
    x, y = SIZE + position[0], SIZE + position[1]

    @positions[x] = [nil] if @positions[x] == nil
    @positions[x - 1] = [nil] if @positions[x - 1] == nil
    @positions[x + 1] = [nil] if @positions[x + 1] == nil

    if @positions[x][y] != nil
      raise PositionNotEmptyException.new("Can not place card over existing card")
    end

    card_to_north = @positions[x][y - 1]
    card_to_east = @positions[x + 1][y]
    card_to_south = @positions[x][y + 1]
    card_to_west = @positions[x - 1][y]

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

    @positions[x][y] = card

  end

  def region(card, corner)
    index_x = @positions.index { |arr| arr.include? card if arr.class == Array }
    if index_x == nil
      raise Exception.new("Card not found on table")
    end
    index_y = @positions[index_x].index(card)
    
    #print "\n", index_x, ",", index_y, ":", corner, "\n"

    data = []

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
          north_east: [:north, [:y, -1, :south_east], [:x, -1, :north_east]],
          north_west: [:west, [:x, -1, :north_east], [:x, -1, :north_west]],
          south_west: [:south, [:y, 1, :north_west], [:x, 1, :south_west]],
          south_east: [:east, [:x, 1, :south_west], [:y, -1, :south_east]]
        }
      when :anti_clockwise
        actions = {
          north_east: [:east, [:x, 1, :north_west], [:y, 1, :north_east]],
          north_west: [:north, [:y, -1, :south_west], [:x, 1, :north_west]],
          south_west: [:west, [:x, -1, :south_east], [:y, -1, :south_west]],
          south_east: [:north, [:y, 1, :north_east], [:x, -1, :south_east]]
        }
      end

      begin # walk anti-clockwise
        data.push yield next_card, next_val[:corner]
        
        bc, yes, no = actions[next_val[:corner]]

        if next_card == nil
          break
        elsif next_card.block_corner?(bc)
          next_val[yes[0]] += yes[1]
          next_val[:corner] = yes[2]
        else
          next_val[no[0]] += no[1]
          next_val[:corner] = no[2]
        end

        next_card = @positions[next_val[:x]][next_val[:y]]

      end until next_card == nil || next_card == card

      break if next_card == card

    end

    data.uniq
  end

  def placeToken(token, card, corner)
    r = region(card, corner) do |next_card, next_corner|
      begin
        #print next_card.to_s, ":", next_corner, " "
        next_card.token.corner == next_corner
      rescue NoMethodError
        false
      end
    end

    #print r

    if r.include?(true)
      raise RegionAlreadyContainsTokenException.new("The region already has a token in it")
    end

    token.corner = corner
    card.token = token
  end

end