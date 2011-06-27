require 'open-uri'
require 'nokogiri'

module Wowget
  class Item
    attr_accessor :id
    attr_accessor :name
    attr_accessor :level
    attr_accessor :quality_id
    attr_accessor :item_class_id
    attr_accessor :item_subclass_id
    attr_accessor :icon_id
    attr_accessor :icon_name
    attr_accessor :required_level
    attr_accessor :inventory_slot_id
    attr_accessor :buy_price
    attr_accessor :sell_price
    attr_accessor :created_by
    attr_accessor :error
    
    ITEM_QUALITIES = ['Poor', 'Common', 'Uncommon', 'Rare', 'Epic', 'Legendary', 'Artifact', 'Heirloom']
    ITEM_CLASSES = {
      0 => 'Consumables',
      1 => 'Containers',
      2 => 'Weapons',
      3 => 'Gems',
      4 => 'Armor',
      7 => 'Trade Goods',
      9 => 'Recipes',
      10 => 'Currency',
      12 => 'Quest',
      13 => 'Keys',
      15 => 'Miscellaneous',
      16 => 'Glyphs'
    }  
    ITEM_SUBCLASSES = {
      'Consumables' => {
        0 => 'Consumables',
        1 => 'Potions',
        2 => 'Elixirs',
        3 => 'Flasks',
        4 => 'Scrolls',
        5 => 'Food & Drinks',
        6 => 'Item Enhancements (Permanent)',
        -3 => 'Item Enhancements (Temporary)',
        7 => 'Bandages',
        8 => 'Other'
      },
      'Containers' => {
        0 => 'Bags',
        2 => 'Herb Bags',
        3 => 'Enchanting Bags',
        4 => 'Engineering Bags',
        5 => 'Gem Bags',
        6 => 'Mining Bags',
        7 => 'Leatherworking Bags',
        8 => 'Inscription Bags',
        9 => 'Tackle Boxes'
      },
      'Weapons' => {
        1 => 'Two-Handed Axes',
        2 => 'Bows',
        3 => 'Guns',
        4 => 'One-Handed Maces',
        5 => 'Two-Handed Maces',
        6 => 'Polearms',
        7 => 'One-Handed Swords',
        8 => 'Two-Handed Swords',
        10 => 'Staves',
        13 => 'Fist Weapons',
        14 => 'Miscellaneous',
        15 => 'Daggers',
        16 => 'Thrown',
        18 => 'Crossbows',
        19 => 'Wands',
        20 => 'Fishing Poles'
      },
      'Gems' => {
        1 => 'Blue',
        2 => 'Yellow',
        3 => 'Purple',
        4 => 'Green',
        5 => 'Orange',
        6 => 'Meta',
        7 => 'Simple',
        8 => 'Prismatic',
        9 => 'Hydraulic',
        10 => 'Cogwheel'
      },
      'Armor' => {
        -8 => 'Shirts',
        -7 => 'Tabards',
        -6 => 'Cloaks',
        -5 => 'Off-hand Frills',
        -4 => 'Trinkets',
        -3 => 'Amulets',
        -2 => 'Rings',
        0 => 'Miscellaneous',
        1 => 'Cloth Armor',
        2 => 'Leather Armor',
        3 => 'Mail Armor',
        4 => 'Plate Armor',
        6 => 'Shields',
        11 => 'Relics'
      },
      'Trade Goods' => {
        1 => 'Parts',
        2 => 'Explosives',
        3 => 'Devices',
        4 => 'Jewelcrafting',
        5 => 'Cloth',
        6 => 'Leather',
        7 => 'Metal & Stone',
        8 => 'Meat',
        9 => 'Herbs',
        10 => 'Elemental',
        11 => 'Other',
        12 => 'Enchanting',
        13 => 'Materials',
        14 => 'Armor Enchantments',
        15 => 'Weapon Enchantments'
      },
      'Recipes' => {
        0 => 'Books ',
        1 => 'Leatherworking Patterns',
        2 => 'Tailoring Patterns',
        3 => 'Engineering Schematics',
        4 => 'Blacksmithing Plans',
        5 => 'Cooking Recipes',
        6 => 'Alchemy Recipes',
        7 => 'First Aid Manuals',
        8 => 'Enchanting Formulae',
        9 => 'Fishing Books',
        10 => 'Jewelcrafting Designs',
        11 => 'Inscription Techniques'
      },
      'Miscellaneous' => {
        -2 => 'Armor Tokens',
        0 => 'Junk',
        1 => 'Reagents',
        2 => 'Companions',
        3 => 'Holiday',
        4 => 'Other',
        5 => 'Mounts'
      },
      'Glyphs' => {
        1 => 'Warrior',
        2 => 'Paladin',
        3 => 'Hunter',
        4 => 'Rogue',
        5 => 'Priest',
        6 => 'Death Knight',
        7 => 'Shaman',
        8 => 'Mage',
        9 => 'Warlock',
        11 => 'Druid'
      }
    }
    INVENTORY_SLOTS = {
      16 => 'Back',
      18 => 'Bag',
      5 => 'Chest',
      8 => 'Feet',
      11 => 'Finger',
      10 => 'Hands',
      1 => 'Head',
      23 => 'Held In Off-hand',
      7 => 'Legs',
      21 => 'Main Hand',
      2 => 'Neck',
      22 => 'Off Hand',
      13 => 'One-Hand',
      24 => 'Projectile',
      15 => 'Ranged',
      28 => 'Relic',
      14 => 'Shield',
      4 => 'Shirt',
      3 => 'Shoulder',
      19 => 'Tabard',
      25 => 'Thrown',
      12 => 'Trinket',
      17 => 'Two-Hand',
      6 => 'Waist',
      9 => 'Wrist'
    }
    
    def initialize(item_id)
      item_xml = Nokogiri::XML(open("http://www.wowhead.com/item=#{item_id}&xml"))
      if item_xml.css('wowhead error').length == 1
        self.error = {:error => "not found"}
      else        
        self.id                = item_id.to_i
        self.name              = item_xml.css('wowhead item name').inner_text.strip.to_s
        self.level             = item_xml.css('wowhead item level').inner_text.strip.to_i
        self.quality_id        = item_xml.css('wowhead item quality').attribute('id').content.to_i
        self.item_class_id     = item_xml.css('wowhead item class').attribute('id').content.to_i
        self.item_subclass_id  = item_xml.css('wowhead item subclass').attribute('id').content.to_i
        self.icon_id           = item_xml.css('wowhead item icon').attribute('displayId').content.to_i
        self.icon_id           = item_xml.css('wowhead item icon').inner_text.strip.to_s
        self.required_level    = nil # parse from JSON
        self.inventory_slot_id = item_xml.css('wowhead item inventorySlot').attribute('id').content.to_i
        self.buy_price         = nil # parse from JSON
        self.sell_price        = nil # parse from JSON
        self.created_by        = nil # parse from XML
        
        if item_xml.css('wowhead item createdBy').length == 1
          # parse reagents
        end
      end
        
# ++
        # if item_xml.css('wowhead item createdBy').length == 1
        #   
        #   self.id = item_id.to_i
        #   self.name = item_xml.css('wowhead item name')
        #   
        #   total_cost = 0
        #   reagents = []
        #   reagents_xml = item_xml.css('wowhead item createdBy spell reagent')
        #   reagents_xml.each do |reagent|
        # 
        #     # determine if this reagent can be bought from a vendor (source: 5)
        #     # TODO: this needs to ignore items sold by vendors for something other than cash!
        #     # reagent_json["source"].include?(5) ? vendor_price(reagent.attribute('id')) : item_value(reagent.attribute('id'))[:precise]
        #     reagent_search = Nokogiri::XML(open("http://www.wowhead.com/item=#{reagent.attribute('id')}&xml"))
        #     reagent_json = JSON "{#{reagent_search.css('wowhead item json').inner_text.strip}}"
        #     item_cost = item_value(reagent.attribute('id'))[:precise]
        #     total_cost += item_cost * reagent.attribute('count').content.to_i
        # 
        #     reagents.push({
        #       :item_id => reagent.attribute('id').to_s,
        #       :name => reagent.attribute('name').to_s,
        #       :icon => reagent.attribute('icon').to_s,
        #       :quality => reagent.attribute('quality').content.to_i,
        #       :quantity => reagent.attribute('count').content.to_i,
        #       :price => item_cost
        #     })
        #   end
        #   recipe = {
        #     :item_id => item_id,
        #     :name => id_search.css('wowhead item name').inner_text.strip.to_s,
        #     :icon => id_search.css('wowhead item icon').inner_text.strip.to_s,
        #     :level => id_search.css('wowhead item level').inner_text.strip,
        #     :quality => id_search.css('wowhead item quality').attribute('id').content.to_i,
        #     :reagents => reagents,
        #     :price => total_cost
        #   }
        #   recipe
        # else
        #   # this item can't be crafted
        #   recipe = {
        #     :item_id => item_id,
        #     :name => id_search.css('wowhead item name').inner_text.strip.to_s,
        #     :icon => id_search.css('wowhead item icon').inner_text.strip.to_s,
        #     :level => id_search.css('wowhead item level').inner_text.strip,
        #     :quality => id_search.css('wowhead item quality').attribute('id').content.to_i,
        #     :reagents => [],
        #     :price => 0,
        #     :notcrafted => true
        #   }
        # end
# --
    end

    def quality
      ITEM_QUALITIES[self.quality_id]
    end
    
    def item_class
      ITEM_CLASSES[self.item_class_id]
    end
    
    def item_subclass
      ITEM_SUBCLASSES[self.item_class][self.item_subclass_id]
    end
    
    def inventory_slot
      INVENTORY_SLOTS[self.inventory_slot_id]
    end
    
  end
end