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
    
    region = [[nil]]
    region[index_x] = [nil] if region[index_x] == nil

    region[index_x][index_y] = card

    next_x, next_y = index_x, index_y
    next_corner = corner

    begin # walk anti-clockwise
      if next_corner == :north_east
        next_x += 1
        next_card = @positions[next_x][next_y]
        next_card.corner = next_corner
        next_corner = :north_west if next_card != nil && next_card.block_corner?(:north)
      elsif next_corner == :north_west
        next_y -= 1
        next_card = @positions[next_x][next_y]
        next_card.corner = next_corner
        next_corner = :south_west if next_card != nil && next_card.block_corner?(:west)
      elsif next_corner == :south_west
        next_x -= 1
        next_card = @positions[next_x][next_y]
        next_card.corner = next_corner
        next_corner = :south_east if next_card != nil && next_card.block_corner?(:south)
      elsif next_corner == :south_east
        next_y += 1
        next_card = @positions[next_x][next_y]
        next_card.corner = next_corner
        next_corner = :north_east if next_card != nil && next_card.block_corner?(:east)
      end
      region[next_x] = [nil] if region[next_x] == nil
      region[next_x][next_y] = next_card
    end until next_card == nil || next_card == card

    if next_card != card
      next_x, next_y = index_x, index_y
      next_corner = corner

      begin # walk clockwise
        if next_corner == :north_east
          next_y -= 1
          next_card = @positions[next_x][next_y]
          next_card.corner = next_corner
          next_corner = :south_east if next_card != nil && next_card.block_corner?(:east)
        elsif next_corner == :south_east
          next_x += 1
          next_card = @positions[next_x][next_y]
          next_card.corner = next_corner
          next_corner = :south_west if next_card != nil && next_card.block_corner?(:south)
        elsif next_corner == :south_west
          next_y += 1
          next_card = @positions[next_x][next_y]
          next_card.corner = next_corner
          next_corner = :north_west if next_card != nil && next_card.block_corner?(:west)
        elsif next_corner == :north_west
          next_x -= 1
          next_card = @positions[next_x][next_y]
          next_card.corner = next_corner
          next_corner = :north_east if next_card != nil && next_card.block_corner?(:north)
        end
        region[next_x] = [nil] if region[next_x] == nil
        region[next_x][next_y] = next_card
      end until next_card == nil || next_card == card
    end

    region
  end

  def placeToken(token, card, corner)
    region = region(card, corner)
    print region.flatten

    token.corner = corner
    card.token = token
  end

end