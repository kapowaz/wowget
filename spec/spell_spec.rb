require_relative "../lib/wowget/item.rb"
require_relative "../lib/wowget/spell.rb"

describe Wowget::Spell do
  
  describe "With a valid ID" do
    spell = Wowget::Spell.new(63188)
    
    it "should have a spell name" do
      spell.name.should == "Battlelord's Plate Boots"
    end
  end
  
  describe "With a non-profession spell" do
    spell = Wowget::Spell.new(49244)
    
    it "should have a spell name" do
      spell.name.should == "Create Eternal Fire"
    end
    
    it "should have the correct quantity of reagents" do
      spell.reagents[0][:quantity].should == 10
    end
    
    it "shouldn't have any profession" do
      spell.profession_id.should == nil and
      spell.profession.should == nil and
      spell.skill.should == nil
    end
  end
  
  describe "With a recipe" do
    spell = Wowget::Spell.new(63188)
    
    it "should have the ID for the item it produces" do
      spell.item_id.should == 45559
    end
    
    it "should have a minimum and maximum number of items produced" do
      spell.item_quantity_min.should == 1 and spell.item_quantity_max.should == 1
    end
    
    it "should have a list of reagents" do
      spell.reagents.length.should == 2 and
      spell.reagents.all? {|r| r[:item].class == Wowget::Item}.should == true and
      spell.reagents[0][:item].name.should == 'Titansteel Bar' and
      spell.reagents[0][:quantity].should == 5 and
      spell.reagents[1][:item].name.should == 'Runed Orb' and
      spell.reagents[1][:quantity].should == 6
    end
    
    it "should have a professional skill requirement" do
      spell.profession_id.should == 2 and
      spell.profession.should == 'Blacksmithing' and
      spell.skill.should == 450
    end
    
    it "should have a source" do
      spell.source.should == "Drop"
    end
  end
  
  describe "Without a recipe" do
    spell = Wowget::Spell.new(50842)
    
    it "shouldn't have an ID for an item" do
      spell.item_id.should == nil
    end
  end
  
  describe "With an invalid ID" do
    spell = Wowget::Spell.new(nil)
    it "should return an error" do
      spell.error.should == {:error => "not found"}
    end   
  end

end