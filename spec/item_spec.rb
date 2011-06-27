require "lib/wowget/item.rb"

describe Wowget::Item do
  it "should return a valid item when a valid item ID is supplied" do
    item = Wowget::Item.new(45559)
    item.id.should == 45559 && item.name.should == "Battlelord's Plate Boots"
  end
  
  it "should return an appropriate error if an invalid item ID is supplied" do
    item = Wowget::Item.new(nil)
    item.id.should == nil && item.error.should == {:error => "not found"}
  end
  
  describe "#quality" do
    it "should return the quality name" do
      item = Wowget::Item.new(45559)
      item.quality.should == "Epic"
    end
  end
  
  describe "#item_class" do
    it "should return the item class name" do
      item = Wowget::Item.new(45559)
      item.item_class.should == "Armor"
    end
  end
  
  describe "#item_subclass" do
    it "should return the item subclass name" do
      item = Wowget::Item.new(45559)
      item.item_subclass.should == "Plate Armor"
    end
  end
  
  describe "#inventory_slot" do
    it "should return the item's inventory slot name" do
      item = Wowget::Item.new(45559)
      item.inventory_slot.should == "Feet"
    end
  end

end