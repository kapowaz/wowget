require_relative "../lib/wowget/item.rb"

describe Wowget::Item do
  
  describe "With a valid ID" do
    item = Wowget::Item.find(4817)
    
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
      item.sell_price.should == 2462 and item.sell_price.class.should == Fixnum
    end
    
    it "should have a vendor buy price" do
      item.buy_price.should == 12311 and item.sell_price.class.should == Fixnum
    end
    
    it "should produce a colorised link" do
      item.to_link.should == "\e[32m[Blessed Claymore]\e[0m"
    end
    
  end
  
  describe "With an ID passed as a string" do
    item = Wowget::Item.find("4817")
    it "should have an item name" do
      item.name.should == "Blessed Claymore"
    end
  end
  
  describe "With a Bind on Pickup item" do
    item = Wowget::Item.find(52078)
    it "should be soulbound" do
      item.soulbound.should == true
    end
  end
  
  describe "With a recipe" do
    item = Wowget::Item.find(55060)
    
    it "should have a recipe spell to create this item" do
      item.recipe_id.should == 76445
    end
  end
  
  describe "With an invalid ID" do
    item = Wowget::Item.find(-1000)
    it "should return the error 'not found'" do
      item.error.should == {:error => "not found"}
    end
  end
  
  describe "With no item ID supplied" do
    item = Wowget::Item.find(nil)
    it "should return the error 'no item ID supplied'" do
      item.error.should == {:error => "no item ID supplied"}
    end
  end
  
  describe "When the name of an item is supplied" do
    item = Wowget::Item.find("Blessed Claymore")
    
    it "should find the appropriate item" do
      item.id.should == 4817
    end
  end

  describe "When an item name with multiple matches is supplied" do
    it "should return an array of items" do
      items = Wowget::Item.find("Titansteel")
      items.class.should == ::Array
      items.length.should == 15
    end
  end

end