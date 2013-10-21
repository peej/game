require "#{File.dirname(__FILE__)}/../card.rb"

describe Card do
  
  it "has a type code" do
    card = Card.new(:through_road, :distributor_road, :access_road, :access_road_no_veh)
    expect(card.type).to eq :tdab

    card = Card.new(:access_road, :access_road_no_veh, :access_road, :access_road_ped_only)
    expect(card.type).to eq :abac
  end

  it "can be created via a type code" do
    card = Card.new(:tdtd)
    expect(card.type).to eq :tdtd
  end

  it "can be rotated clockwise" do
    card = Card.new(:through_road, :distributor_road, :access_road, :access_road_no_veh)
    card.rotate(:clockwise)
    expect(card.type).to eq :btda
  end

  it "can be rotated anti-clockwise" do
    card = Card.new(:through_road, :distributor_road, :access_road, :access_road_no_veh)
    card.rotate(:anti_clockwise)
    expect(card.type).to eq :dabt
  end

  it "can be rotated 180" do
    card = Card.new(:through_road, :distributor_road, :access_road, :access_road_no_veh)
    card.rotate(:one_eighty)
    expect(card.type).to eq :abtd
  end

  it "can output itself as ascii art" do
    card = Card.new(:through_road, :distributor_road, :access_road, :access_road_no_veh)
    output = card.to_s
    expect(output + "\n").to eq <<-EOF
+---+
| t |
|b+d|
| a |
+---+
EOF

    card = Card.new(:access_road, :access_road_no_veh, :access_road_ped_only, :through_road)
    output = card.to_s
    expect(output + "\n").to eq <<-EOF
+---+
| a |
|t+b|
| c |
+---+
EOF
  end

end