class Token

  attr_accessor :corner, :type

  def initialize(type = :pedestrian)
    @type = type
  end

end