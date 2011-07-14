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
    SUBCATEGORIES = {
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
      1 => 'Head',
      2 => 'Neck',
      3 => 'Shoulder',
      4 => 'Shirt',
      5 => 'Chest',
      6 => 'Waist',
      7 => 'Legs',
      8 => 'Feet',
      9 => 'Wrist',
      10 => 'Hands',
      11 => 'Finger',
      12 => 'Trinket',
      13 => 'One-Hand',
      14 => 'Shield',
      15 => 'Ranged',
      16 => 'Back',
      17 => 'Two-Hand',
      18 => 'Bag',
      19 => 'Tabard',
      21 => 'Main Hand',
      22 => 'Off Hand',
      23 => 'Held In Off-hand',
      24 => 'Projectile',
      25 => 'Thrown',
      28 => 'Relic'
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
    
    def subcategory
      SUBCATEGORIES[self.category][self.subcategory_id]
    end
    
    def inventory_slot
      INVENTORY_SLOTS[self.inventory_slot_id]
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