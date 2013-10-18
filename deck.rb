require "#{File.dirname(__FILE__)}/card.rb"

class Deck < Array
  
  def initialize
    (0...4).each { |card| self.push Card.new(:through_road, :through_road, :through_road, :through_road) }
    (0...8).each { |card| self.push Card.new(:through_road, :distributor_road, :through_road, :distributor_road) }
    (0...12).each { |card| self.push Card.new(:through_road, :access_road_no_veh, :through_road, :access_road_no_veh) }
    (0...8).each { |card| self.push Card.new(:through_road, :distributor_road, :through_road, :access_road_no_veh) }

    (0...4).each { |card| self.push Card.new(:distributor_road, :distributor_road, :distributor_road, :distributor_road) }
    (0...12).each { |card| self.push Card.new(:distributor_road, :access_road, :distributor_road, :access_road) }
    (0...4).each { |card| self.push Card.new(:distributor_road, :access_road_no_veh, :distributor_road, :access_road_no_veh) }
    (0...4).each { |card| self.push Card.new(:distributor_road, :access_road, :distributor_road, :access_road_no_veh) }
    (0...4).each { |card| self.push Card.new(:distributor_road, :distributor_road, :distributor_road, :access_road) }
    (0...4).each { |card| self.push Card.new(:distributor_road, :distributor_road, :distributor_road, :access_road_no_veh) }
    (0...4).each { |card| self.push Card.new(:distributor_road, :distributor_road, :access_road, :access_road) }
    (0...4).each { |card| self.push Card.new(:distributor_road, :access_road, :access_road, :access_road) }

    (0...12).each { |card| self.push Card.new(:access_road, :access_road, :access_road, :access_road) }
    (0...4).each { |card| self.push Card.new(:access_road, :access_road_no_veh, :access_road, :access_road_no_veh) }
    (0...4).each { |card| self.push Card.new(:access_road, :access_road_ped_only, :access_road, :access_road_ped_only) }
  end

  def draw
    self.pop
  end

end