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
      item.category_id.should == 2
    end
    
    it "should have an item class name" do
      item.category.should == "Weapons"
    end

    it "should have an item subclass value" do
      item.subcategory_id.should == 8
    end

    it "should have an item subclass name" do
      item.subcategory.should == "Two-Handed Swords"
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
      item.sell_price.should == 0.2462
    end
    
    it "should have a vendor buy price" do
      item.buy_price.should == 1.2311
    end
    
    it "should produce a colorised link" do
      item.to_link.should == "\e[32m[Blessed Claymore]\e[0m"
    end
    
  end
  
  describe "With an ID passed as a string" do
    item = Wowget::Item.new("4817")
    it "should have an item name" do
      item.name.should == "Blessed Claymore"
    end
  end
  
  describe "With a recipe" do
    item = Wowget::Item.new(45559)
    
    it "should have a recipe spell to create this item" do
      item.recipe_id.should == 63188
    end
  end
  
  describe "With an invalid ID" do
    item = Wowget::Item.new(-1000)
    it "should return an error" do
      item.error.should == {:error => "not found"}
    end
  end
  
  describe "With no item ID supplied" do
    item = Wowget::Item.new(nil)
    it "should return an error" do
      item.error.should == {:error => "no item ID supplied"}
    end
  end
  
  describe "When the name of an item is supplied" do
    item = Wowget::Item.new("Blessed Claymore")
    
    it "should find the appropriate item" do
      item.id.should == 4817
    end
  end

end