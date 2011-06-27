require 'open-uri'
require 'nokogiri'

module Wowget
  class Spell
    attr_accessor :id
    attr_accessor :name
    attr_accessor :item_id
    attr_accessor :reagents
    attr_accessor :profession
    attr_accessor :skill_level
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
          self.item_id = spell_xml.css('table#spelldetails td span.q4 a').attribute('href').content.scan(/\/item=([0-9]+)/)[0][0].to_i          
        end
        
        # reagents
        if spell_xml.css("h3:contains('Reagents')").length == 1
          self.reagents = []
          reagents = spell_xml.css("h3:contains('Reagents')+table.iconlist tr td")
          reagents.each do |r|
            item_id = r.css("span a").attribute('href').content.scan(/\/item=([0-9]+)/)[0][0].to_i
            quantity = r.content.scan(/\(([0-9]+)\)$/)[0][0].to_i
            self.reagents.push({:item => Wowget::Item.new(item_id), :quantity => quantity})
          end
        end
        
        # profession
        unless self.item_id.nil?
          p = spell_xml.xpath("//script[contains(., 'Markup')]").inner_text.scan(/\[ul\]\[li\](.+?)\[\/li\]/)[0][0].scan(/Requires (.+?) \(([0-9]+?)\)/)[0]
          self.profession = p[0]
          self.skill_level = p[1].to_i
        end
      end
    end
    
  end
end