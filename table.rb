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

  end

  def placeCard(card, position)
    
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

    if card_to_north != nil && card_to_north.south != card.north
      raise CardDoesNotFitException.new("Card does not fit next to card to the north")
    end
    if card_to_east != nil && card_to_east.west != card.east
      raise CardDoesNotFitException.new("Card does not fit next to card to the east")
    end
    if card_to_south != nil && card_to_south.north != card.south
      raise CardDoesNotFitException.new("Card does not fit next to card to the south")
    end
    if card_to_west != nil && card_to_west.east != card.west
      raise CardDoesNotFitException.new("Card does not fit next to card to the west")
    end

    @positions[x][y] = card

  end

  def region(card, corner)
    index_x = @positions.index { |arr| arr.include? card if arr.class == Array }
    return nil if index_x == nil
    index_y = @positions[index_x].index(card)
    
    data = []
    data.push yield card, corner

    next_card = nil
    next_val = {
      x: index_x,
      y: index_y,
      corner: corner
    }

    begin # walk anti-clockwise
      [
        [:north_east, :x, 1, :north_west, :north],
        [:north_west, :y, -1, :south_west, :west],
        [:south_west, :x, -1, :south_east, :south],
        [:south_east, :y, 1, :north_east, :east]
      ].each do |c, dir, amm, nc, bc|
        if next_val[:corner] == c
          next_val[dir] += amm
          next_card = @positions[next_val[:x]][next_val[:y]]
          next_val[:corner] = nc if next_card != nil && next_card.block_corner?(bc)
          break
        end
      end
      data.push yield next_card, next_val[:corner] if next_card != nil
    end until next_card == nil || next_card == card

    if next_card != card # not an enclosed region
      next_val = {
        x: index_x,
        y: index_y,
        corner: corner
      }

      begin # walk clockwise
        [
          [:north_east, :y, -1, :south_east, :east],
          [:south_east, :x, 1, :south_west, :south],
          [:south_west, :y, 1, :north_west, :west],
          [:north_west, :x, -1, :north_east, :north],
        ].each do |c, dir, amm, nc, bc|
          if next_val[:corner] == c
            next_val[dir] += amm
            next_card = @positions[next_val[:x]][next_val[:y]]
            next_val[:corner] = nc if next_card != nil && next_card.block_corner?(bc)
            break
          end
        end
        data.push yield next_card, next_val[:corner] if next_card != nil
      end until next_card == nil || next_card == card
    end

    data
  end

  def placeToken(token, card, corner)
    r = region(card, corner) do |next_card, next_corner|
      begin
        next_card.token.corner == next_corner
      rescue NoMethodError
        false
      end
    end
    if r.include?(true)
      raise RegionAlreadyContainsTokenException.new("The region already has a token in it")
    end

    token.corner = corner
    card.token = token
  end

end