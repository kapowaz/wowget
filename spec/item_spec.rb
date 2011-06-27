require "lib/wowget/item.rb"

describe Wowget::Item do
  
  describe "With a valid item ID" do
    item = Wowget::Item.new(45559)
    
    it "should have an item name" do
      item.name.should == "Battlelord's Plate Boots"
    end
    
    it "should have an item level" do
      item.level.should == 226
    end
    
    it "should have a quality value" do
      item.quality_id.should == 4
    end
    
    it "should have a quality name" do
      item.quality.should == "Epic"
    end
    
    it "should have an item class value" do
      item.item_class_id.should == 4
    end
    
    it "should have an item class name" do
      item.item_class.should == "Armor"
    end

    it "should have an item subclass value" do
      item.item_subclass_id.should == 4
    end

    it "should have an item subclass name" do
      item.item_subclass.should == "Plate Armor"
    end
    
    it "should have an icon value" do
      item.icon_id.should == 97660
    end
    
    it "should have an icon name" do
      item.icon_name.should == "INV_Boots_Plate_06"
    end
    
    it "should have an inventory slot value" do
      item.inventory_slot_id.should == 8
    end
    
    it "should have an inventory slot name" do
      item.inventory_slot.should == "Feet"
    end
    
  end
  
  it "should return an appropriate error if an invalid item ID is supplied" do
    item = Wowget::Item.new(nil)
    item.id.should == nil && item.error.should == {:error => "not found"}
  end

end