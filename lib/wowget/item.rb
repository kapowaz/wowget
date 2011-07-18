require 'net/http'
require 'open-uri'
require 'nokogiri'
require 'json'
require 'colored'

module Wowget
  class Item
    attr_accessor :id
    attr_accessor :name
    attr_accessor :level
    attr_accessor :quality_id
    attr_accessor :category_id
    attr_accessor :subcategory_id
    attr_accessor :icon_id
    attr_accessor :icon_name
    attr_accessor :required_level
    attr_accessor :inventory_slot_id
    attr_accessor :buy_price
    attr_accessor :sell_price
    attr_accessor :recipe_id
    attr_accessor :soulbound
    attr_accessor :error
    
    QUALITIES = ['Poor', 'Common', 'Uncommon', 'Rare', 'Epic', 'Legendary', 'Artifact', 'Heirloom']
    CATEGORIES = {
      0 => {:name => 'Consumables', :slug => 'consumables'},
      1 => {:name => 'Containers', :slug => 'containers'},
      2 => {:name => 'Weapons', :slug => 'weapons'},
      3 => {:name => 'Gems', :slug => 'gems'},
      4 => {:name => 'Armor', :slug => 'armor'},
      7 => {:name => 'Trade Goods', :slug => 'tradegoods'},
      9 => {:name => 'Recipes', :slug => 'recipes'},
      10 => {:name => 'Currency', :slug => 'currency'},
      12 => {:name => 'Quest', :slug => 'quest'},
      13 => {:name => 'Keys', :slug => 'keys'},
      15 => {:name => 'Miscellaneous', :slug => 'miscellaneous'},
      16 => {:name => 'Glyphs', :slug => 'glyphs'}
    }  
    SUBCATEGORIES = {
      'Consumables' => {
        0 => {:name => 'Consumables', :slug => 'consumables'},
        1 => {:name => 'Potions', :slug => 'potions'},
        2 => {:name => 'Elixirs', :slug => 'elixirs'},
        3 => {:name => 'Flasks', :slug => 'flasks'},
        4 => {:name => 'Scrolls', :slug => 'scrolls'},
        5 => {:name => 'Food & Drinks', :slug => 'food_and_drinks'},
        6 => {:name => 'Item Enhancements (Permanent)', :slug => 'item_enhancements_permanent'},
        -3 => {:name => 'Item Enhancements (Temporary)', :slug => 'item_enhancements_temporary'},
        7 => {:name => 'Bandages', :slug => 'bandages'},
        8 => {:name => 'Other', :slug => 'other'}
      },
      'Containers' => {
        0 => {:name => 'Bags', :slug => 'bags'},
        2 => {:name => 'Herb Bags', :slug => 'herb'},
        3 => {:name => 'Enchanting Bags', :slug => 'enchanting'},
        4 => {:name => 'Engineering Bags', :slug => 'engineering'},
        5 => {:name => 'Gem Bags', :slug => 'gem'},
        6 => {:name => 'Mining Bags', :slug => 'mining'},
        7 => {:name => 'Leatherworking Bags', :slug => 'leatherworking'},
        8 => {:name => 'Inscription Bags', :slug => 'inscription'},
        9 => {:name => 'Tackle Boxes', :slug => 'tackleboxes'}
      },
      'Weapons' => {
        1 => {:name => 'Two-Handed Axes', :slug => 'two_handed_axes'},
        2 => {:name => 'Bows', :slug => 'bows'},
        3 => {:name => 'Guns', :slug => 'guns'},
        4 => {:name => 'One-Handed Maces', :slug => 'one_handed_maces'},
        5 => {:name => 'Two-Handed Maces', :slug => 'two_handed_maces'},
        6 => {:name => 'Polearms', :slug => 'polearms'},
        7 => {:name => 'One-Handed Swords', :slug => 'one_handed_swords'},
        8 => {:name => 'Two-Handed Swords', :slug => 'two_handed_swords'},
        10 => {:name => 'Staves', :slug => 'staves'},
        13 => {:name => 'Fist Weapons', :slug => 'fist_weapons'},
        14 => {:name => 'Miscellaneous', :slug => 'miscellaneous'},
        15 => {:name => 'Daggers', :slug => 'daggers'},
        16 => {:name => 'Thrown', :slug => 'thrown'},
        18 => {:name => 'Crossbows', :slug => 'crossbows'},
        19 => {:name => 'Wands', :slug => 'wands'},
        20 => {:name => 'Fishing Poles', :slug => 'fishing_poles'}
      },
      'Gems' => {
        1 => {:name => 'Blue', :slug => 'blue'},
        2 => {:name => 'Yellow', :slug => 'yellow'},
        3 => {:name => 'Purple', :slug => 'purple'},
        4 => {:name => 'Green', :slug => 'green'},
        5 => {:name => 'Orange', :slug => 'orange'},
        6 => {:name => 'Meta', :slug => 'meta'},
        7 => {:name => 'Simple', :slug => 'simple'},
        8 => {:name => 'Prismatic', :slug => 'prismatic'},
        9 => {:name => 'Hydraulic', :slug => 'hydraulic'},
        10 => {:name => 'Cogwheel', :slug => 'cogwheel'}
      },
      'Armor' => {
        -8 => {:name => 'Shirts', :slug => 'shirts'},
        -7 => {:name => 'Tabards', :slug => 'tabards'},
        -6 => {:name => 'Cloaks', :slug => 'cloaks'},
        -5 => {:name => 'Off-hand Frills', :slug => 'off_hand_frills'},
        -4 => {:name => 'Trinkets', :slug => 'trinkets'},
        -3 => {:name => 'Amulets', :slug => 'amulets'},
        -2 => {:name => 'Rings', :slug => 'rings'},
        0 => {:name => 'Miscellaneous', :slug => 'miscellaneous'},
        1 => {:name => 'Cloth', :slug => 'cloth', :inventoryslots => true},
        2 => {:name => 'Leather', :slug => 'leather', :inventoryslots => true},
        3 => {:name => 'Mail', :slug => 'mail', :inventoryslots => true},
        4 => {:name => 'Plate', :slug => 'plate', :inventoryslots => true},
        6 => {:name => 'Shields', :slug => 'shields'},
        11 => {:name => 'Relics', :slug => 'relics'}
      },
      'Trade Goods' => {
        1 => {:name => 'Parts', :slug => 'parts'},
        2 => {:name => 'Explosives', :slug => 'explosives'},
        3 => {:name => 'Devices', :slug => 'devices'},
        4 => {:name => 'Jewelcrafting', :slug => 'jewelcrafting'},
        5 => {:name => 'Cloth', :slug => 'cloth'},
        6 => {:name => 'Leather', :slug => 'leather'},
        7 => {:name => 'Metal & Stone', :slug => 'metal_and_stone'},
        8 => {:name => 'Meat', :slug => 'meat'},
        9 => {:name => 'Herbs', :slug => 'herbs'},
        10 => {:name => 'Elemental', :slug => 'elemental'},
        11 => {:name => 'Other', :slug => 'other'},
        12 => {:name => 'Enchanting', :slug => 'enchanting'},
        13 => {:name => 'Materials', :slug => 'materials'},
        14 => {:name => 'Armor Enchantments', :slug => 'armor_enchantments'},
        15 => {:name => 'Weapon Enchantments', :slug => 'weapon_enchantments'}
      },
      'Recipes' => {
        0 => {:name => 'Books ', :slug => 'books'},
        1 => {:name => 'Leatherworking Patterns', :slug => 'leatherworking'},
        2 => {:name => 'Tailoring Patterns', :slug => 'tailoring'},
        3 => {:name => 'Engineering Schematics', :slug => 'engineering'},
        4 => {:name => 'Blacksmithing Plans', :slug => 'blacksmithing'},
        5 => {:name => 'Cooking Recipes', :slug => 'cooking'},
        6 => {:name => 'Alchemy Recipes', :slug => 'alchemy'},
        7 => {:name => 'First Aid Manuals', :slug => 'first_aid'},
        8 => {:name => 'Enchanting Formulae', :slug => 'enchanting'},
        9 => {:name => 'Fishing Books', :slug => 'fishing'},
        10 => {:name => 'Jewelcrafting Designs', :slug => 'jewelcrafting'},
        11 => {:name => 'Inscription Techniques', :slug => 'inscription'}
      },
      'Miscellaneous' => {
        -2 => {:name => 'Armor Tokens', :slug => 'armor_tokens'},
        0 => {:name => 'Junk', :slug => 'junk'},
        1 => {:name => 'Reagents', :slug => 'reagents'},
        2 => {:name => 'Companions', :slug => 'companions'},
        3 => {:name => 'Holiday', :slug => 'holiday'},
        4 => {:name => 'Other', :slug => 'other'},
        5 => {:name => 'Mounts', :slug => 'mounts'}
      },
      'Glyphs' => {
        1 => {:name => 'Warrior', :slug => 'warrior'},
        2 => {:name => 'Paladin', :slug => 'paladin'},
        3 => {:name => 'Hunter', :slug => 'hunter'},
        4 => {:name => 'Rogue', :slug => 'rogue'},
        5 => {:name => 'Priest', :slug => 'priest'},
        6 => {:name => 'Death Knight', :slug => 'death_knight'},
        7 => {:name => 'Shaman', :slug => 'shaman'},
        8 => {:name => 'Mage', :slug => 'mage'},
        9 => {:name => 'Warlock', :slug => 'warlock'},
        11 => {:name => 'Druid', :slug => 'druid'}
      }
    }
    INVENTORY_SLOTS = {
      1 => {:name => 'Head', :slug => 'head', :armor => true},
      2 => {:name => 'Neck', :slug => 'neck'},
      3 => {:name => 'Shoulder', :slug => 'shoulder', :armor => true},
      4 => {:name => 'Shirt', :slug => 'shirt'},
      5 => {:name => 'Chest', :slug => 'chest', :armor => true},
      6 => {:name => 'Waist', :slug => 'waist', :armor => true},
      7 => {:name => 'Legs', :slug => 'legs', :armor => true},
      8 => {:name => 'Feet', :slug => 'feet', :armor => true},
      9 => {:name => 'Wrist', :slug => 'wrist', :armor => true},
      10 => {:name => 'Hands', :slug => 'hands', :armor => true},
      11 => {:name => 'Finger', :slug => 'finger'},
      12 => {:name => 'Trinket', :slug => 'trinket'},
      13 => {:name => 'One-Hand', :slug => 'one_hand'},
      14 => {:name => 'Shield', :slug => 'shield'},
      15 => {:name => 'Ranged', :slug => 'ranged'},
      16 => {:name => 'Back', :slug => 'back'},
      17 => {:name => 'Two-Hand', :slug => 'two_hand'},
      18 => {:name => 'Bag', :slug => 'bag'},
      19 => {:name => 'Tabard', :slug => 'tabard'},
      21 => {:name => 'Main Hand', :slug => 'main_hand'},
      22 => {:name => 'Off Hand', :slug => 'off_hand'},
      23 => {:name => 'Held In Off-hand', :slug => 'held_in_off_hand'},
      24 => {:name => 'Projectile', :slug => 'projectile'},
      25 => {:name => 'Thrown', :slug => 'thrown'},
      28 => {:name => 'Relic', :slug => 'relic'}
    }
    
    def self.find(query)
      item_ids = []
      items    = []
      
      if query.class == Fixnum
        # easy — e.g. 12345
        item_ids << query
      elsif query.class == String
        # try parsing a number, e.g. "12345"
        item_id = id_from_string(query)
        
        unless item_id.nil?
          item_ids << item_id
        else
          # try searching for this item by name
          item_redirect = Net::HTTP.get_response(URI.parse("http://www.wowhead.com/search?q=#{uri_escape(query)}"))["Location"]
          if item_redirect
            item_ids << item_redirect.match(/^\/item=([1-9][0-9]*)$/)[1].to_i
          else
            # try retrieving a list of items that match the supplied query
            begin
              # horrendously messy. fuck you very much, wowhead.
              item_json = JSON Nokogiri::XML(open("http://www.wowhead.com/search?q=#{uri_escape(query)}")).inner_text.match(/new Listview\(\{template: 'item'.*, data: (\[.*\])\}\);$/)[1]
            rescue
              no_results = true
            end
            
            if no_results || item_json.length == 0
              self.error = {:error => "no items found"}
            else
              item_json.each do |item|
                item_ids << item["id"].to_i
              end
            end
          end
        end
      elsif query.class == NilClass
        item_ids << nil
      end
      
      if item_ids.length > 0
        item_ids.each do |item_id|
          items << Wowget::Item.new(item_id)
        end
      end
      
      items.length == 1 ? items[0] : items
    end
    
    def self.inventory_slot_from_slug(slug)
      found = nil
      INVENTORY_SLOTS.each_pair do |id, slot|
        found = slot.merge(:id => id) if slot[:slug] == slug
      end
      found
    end
    
    def initialize(item_id)
      item_xml = Nokogiri::XML(open("http://www.wowhead.com/item=#{item_id}&xml"))
      if item_id.nil?
        self.error = {:error => "no item ID supplied"}
      elsif item_xml.css('wowhead error').length == 1
        self.error = {:error => "not found"}
      else
        item_json              = JSON "{#{item_xml.css('wowhead item json').inner_text.strip.to_s}}"
        item_equip_json        = JSON "{#{item_xml.css('wowhead item jsonEquip').inner_text.strip.to_s}}"
        self.id                = item_id.to_i
        self.name              = item_xml.css('wowhead item name').inner_text.strip.to_s
        self.level             = item_xml.css('wowhead item level').inner_text.strip.to_i
        self.quality_id        = item_xml.css('wowhead item quality').attribute('id').content.to_i
        self.category_id       = item_xml.css('wowhead item class').attribute('id').content.to_i
        self.subcategory_id    = item_xml.css('wowhead item subclass').attribute('id').content.to_i
        self.icon_id           = item_xml.css('wowhead item icon').attribute('displayId').content.to_i
        self.icon_name         = item_xml.css('wowhead item icon').inner_text.strip.to_s
        self.required_level    = item_json['reqlevel']
        self.inventory_slot_id = item_xml.css('wowhead item inventorySlot').attribute('id').content.to_i
        self.buy_price         = item_equip_json['buyprice'].to_i
        self.sell_price        = item_equip_json['sellprice'].to_i
        self.soulbound         = item_xml.css('wowhead item htmlTooltip').inner_text.match('Binds when picked up') ? true : false

        if item_xml.css('wowhead item createdBy').length == 1
          self.recipe_id = item_xml.css('wowhead item createdBy spell').attribute('id').content.to_i
        end
      end
    end

    def quality
      QUALITIES[self.quality_id]
    end
    
    def category
      CATEGORIES[self.category_id]
    end
    
    def category_name
      CATEGORIES[self.category_id][:name]
    end
    
    def category_slug
      CATEGORIES[self.category_id][:slug]
    end
    
    def subcategory
      SUBCATEGORIES[self.category[:name]][self.subcategory_id]
    end
    
    def subcategory_name
      SUBCATEGORIES[self.category[:name]][self.subcategory_id][:name]
    end
    
    def subcategory_slug
      SUBCATEGORIES[self.category[:name]][self.subcategory_id][:slug]
    end
    
    def inventory_slot
      INVENTORY_SLOTS[self.inventory_slot_id]
    end
    
    def inventory_slot_name
      self.inventory_slot_id == 0 ? nil : INVENTORY_SLOTS[self.inventory_slot_id][:name]
    end
    
    def inventory_slot_slug
      self.inventory_slot_id == 0 ? nil : INVENTORY_SLOTS[self.inventory_slot_id][:slug]      
    end
    
    def to_link
      color = case self.quality.downcase.to_sym
      when :poor then 'white'
      when :common then 'white'
      when :uncommon then 'green'
      when :rare then 'blue'
      when :epic then 'magenta'
      when :legendary then 'red'
      when :artifact then 'yellow'
      when :heirloom then 'yellow'
      end
      Colored.colorize "[#{self.name}]", :foreground => color
    end
    
    private
    
    def self.id_from_string(string)
      string.to_i if string.match /^[1-9][0-9]*$/
    end
    
    def self.uri_escape(string)
      URI.escape(string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    end
    
  end
end