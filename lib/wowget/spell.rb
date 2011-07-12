require 'open-uri'
require 'nokogiri'
require 'json'

module Wowget
  class Spell
    attr_accessor :id
    attr_accessor :name
    attr_accessor :item_id
    attr_accessor :item_quantity_min
    attr_accessor :item_quantity_max
    attr_accessor :reagents
    attr_accessor :profession
    attr_accessor :profession_id
    attr_accessor :skill
    attr_accessor :skillup
    attr_accessor :source_id
    attr_accessor :error

    def initialize(spell_id)
      begin
        url = open("http://www.wowhead.com/spell=#{spell_id}")
      rescue
        not_found = true
      end
      
      spell_xml = Nokogiri::XML(url) unless not_found
      
      if not_found || spell_xml.css('div#inputbox-error').length == 1
        self.error = {:error => "not found"}
      else
        self.name = spell_xml.css('div.text h1').inner_text.strip.to_s
        
        # retrieve recipe data
        recipe = spell_xml.inner_text.match(/^new Listview\(\{template: 'spell', id: 'recipes', .*, data: (\[\{.*\}\])\}\);$/)
        unless recipe.nil?
          recipe_json = (JSON recipe[1])[0]
          
          unless recipe_json["creates"].nil?
            # item produced and quantity
            self.item_id           = recipe_json["creates"][0]
            self.item_quantity_min = recipe_json["creates"][1]
            self.item_quantity_max = recipe_json["creates"][2]
            
            # profession
            unless recipe_json["skill"].nil?
              profession         = wowhead_profession(recipe_json["skill"][0])
              self.profession    = profession[:name]
              self.profession_id = profession[:id]
              self.skill         = recipe_json["learnedat"]
              self.skillup       = recipe_json["nskillup"]
              self.source_id     = recipe_json["source"][0]
            end
            
            # reagents
            self.reagents = []
            recipe_json["reagents"].each do |reagent|
              item_id  = reagent[0]
              quantity = self.profession_id.nil? ? reagent[1] + 1 : reagent[1]
              self.reagents.push({:item => Wowget::Item.new(item_id), :quantity => quantity})
            end 
          end
        end
        
      end
    end
    
    def source
      case self.source_id
        when 1 then "Crafted"
        when 2 then "Drop"
        when 3 then "PvP"
        when 4 then "Quest"
        when 5 then "Vendor"
        when 6 then "Trainer"
        when 7 then "Discovery"
        when 8 then "Redemption"
        when 9 then "Talent"
        when 10 then "Starter"
        when 11 then "Event"
        when 12 then "Achievement"
      end
    end
    
    private
    
    def wowhead_profession(id)
      case id
        when 171 then {:name => "Alchemy",        :id => 1}
        when 164 then {:name => "Blacksmithing",  :id => 2}
        when 333 then {:name => "Enchanting",     :id => 4}
        when 202 then {:name => "Engineering",    :id => 5}
        when 182 then {:name => "Herbalism",      :id => 14}
        when 773 then {:name => "Inscription",    :id => 15}
        when 755 then {:name => "Jewelcrafting",  :id => 7}
        when 165 then {:name => "Leatherworking", :id => 8}
        when 186 then {:name => "Mining",         :id => 9}
        when 197 then {:name => "Tailoring",      :id => 10}
        when 794 then {:name => "Archaeology",    :id => 16}
        when 185 then {:name => "Cooking",        :id => 3}
        when 129 then {:name => "First Aid",      :id => 6}
      end
    end
    
  end
end