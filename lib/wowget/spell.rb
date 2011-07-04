require 'open-uri'
require 'nokogiri'

module Wowget
  class Spell
    attr_accessor :id
    attr_accessor :name
    attr_accessor :item_id
    attr_accessor :reagents
    attr_accessor :profession
    attr_accessor :profession_id
    attr_accessor :skill
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
        
        if spell_xml.css('table#spelldetails td span.q4 a').length == 1
          self.item_id = spell_xml.css('table#spelldetails td span.q4 a').attribute('href').content.match(/\/item=([0-9]+)/)[1].to_i
        end
        
        # reagents
        if spell_xml.css("h3:contains('Reagents')").length == 1
          self.reagents = []
          reagents = spell_xml.css("h3:contains('Reagents')+table.iconlist tr td")
          reagents.each do |r|
            item_id = r.css("span a").attribute('href').content.match(/\/item=([0-9]+)/)[1].to_i
            quantity = r.content.match(/\(([0-9]+)\)$/)[1].to_i
            self.reagents.push({:item => Wowget::Item.new(item_id), :quantity => quantity})
          end
        end
        
        # profession
        unless self.item_id.nil?
          matches = spell_xml.xpath("//script[contains(., 'Markup')]").inner_text.match(/\[ul\]\[li\](.+?)\[\/li\]/)[1].match(/Requires (.+?) \(([0-9]+?)\)/)
          self.profession = matches[1]
          self.skill = matches[2].to_i
          
          self.profession_id = case self.profession
            when "Alchemy" then 1
            when "Blacksmithing" then 2
            when "Cooking" then 3
            when "Enchanting" then 4
            when "Engineering" then 5
            when "First Aid" then 6
            when "Jewelcrafting" then 7
            when "Leatherworking" then 8
            when "Mining" then 9
            when "Tailoring" then 10
            when "Yes" then 11
            when "No" then 12
            when "Fishing" then 13
            when "Herbalism" then 14
            when "Inscription" then 15
            when "Archaeology" then 16
          end
          
        end
      end
    end
    
  end
end