require_relative "../lib/wowget/item.rb"

describe Wowget::Item do
  
  describe "With a valid ID" do
    item = Wowget::Item.new(4817)
    
    it "should have an item name" do
      item.name.should == "Blessed Claymore"
    end
    
    it "should have an item level" do
      item.level.should == 22
    end
    
    it "should have a quality value" do
      item.quality_id.should == 2
    end
    
    it "should have a quality name" do
      item.quality.should == "Uncommon"
    end
    
    it "should have an item class value" do
      item.item_class_id.should == 2
    end
    
    it "should have an item class name" do
      item.item_class.should == "Weapons"
    end

    it "should have an item subclass value" do
      item.item_subclass_id.should == 8
    end

    it "should have an item subclass name" do
      item.item_subclass.should == "Two-Handed Swords"
    end
    
    it "should have an icon value" do
      item.icon_id.should == 7319
    end
    
    it "should have an icon name" do
      item.icon_name.should == "INV_Sword_13"
    end
    
    it "should have an inventory slot value" do
      item.inventory_slot_id.should == 17
    end
    
    it "should have an inventory slot name" do
      item.inventory_slot.should == "Two-Hand"
    end
    
    it "should have a required minimum level" do
      item.required_level.should == 17
    end
    
    it "should have a vendor sell price" do
      item.sell_price.should == 2462
    end
    
    it "should have a vendor buy price" do
      item.buy_price.should == 12311
    end
    
  end
  
  describe "With a recipe" do
    item = Wowget::Item.new(45559)
    
    it "should have a recipe spell to create this item" do
      item.recipe_id.should == 63188
    end
  end
  
  describe "With an invalid ID" do
    item = Wowget::Item.new(nil)
    it "should return an error" do
      item.error.should == {:error => "not found"}
    end   
  end
  
  describe "With an item name" do
    
  end

end